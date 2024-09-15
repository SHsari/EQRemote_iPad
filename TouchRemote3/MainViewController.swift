//
//  ViewController.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import UIKit

var globalBands: [OneBand] = factoryPreset_().bands

var parameterViewArray: [ParameterView] = []

var pendingTaskBand = OneBand()

var pendingTaskPreset = factoryPreset_()


class MainViewController: UIViewController {
    
    @IBOutlet weak var sectionController: UISegmentedControl!
    
    @IBOutlet weak var pViewSection1: UIView!
    @IBOutlet weak var pViewSection2: UIView!
    
    @IBOutlet var paramView1: UIView!
    @IBOutlet var paramView2: UIView!
    @IBOutlet var paramView3: UIView!
    @IBOutlet var paramView4: UIView!
    @IBOutlet var paramView5: UIView!
    @IBOutlet var paramView6: UIView!
    @IBOutlet var paramView7: UIView!
    @IBOutlet var paramView8: UIView!
    
    private lazy var paramViews_ = [paramView1, paramView2, paramView3, paramView4, paramView5, paramView6, paramView7, paramView8]
    
    @IBOutlet weak var bandSwitch1: UISwitch!
    @IBOutlet weak var bandSwitch2: UISwitch!
    @IBOutlet weak var bandSwitch3: UISwitch!
    @IBOutlet weak var bandSwitch4: UISwitch!
    @IBOutlet weak var bandSwitch5: UISwitch!
    @IBOutlet weak var bandSwitch6: UISwitch!
    @IBOutlet weak var bandSwitch7: UISwitch!
    @IBOutlet weak var bandSwitch8: UISwitch!
    
    private lazy var bandSwitches = [bandSwitch1, bandSwitch2, bandSwitch3, bandSwitch4, bandSwitch5, bandSwitch6, bandSwitch7, bandSwitch8]
    
    @IBOutlet var filterButton1: UIButton!
    @IBOutlet var filterButton2: UIButton!
    @IBOutlet var filterButton3: UIButton!
    @IBOutlet var filterButton4: UIButton!
    @IBOutlet var filterButton5: UIButton!
    @IBOutlet var filterButton6: UIButton!
    @IBOutlet var filterButton7: UIButton!
    @IBOutlet var filterButton8: UIButton!
    
    lazy var filterButtons = [filterButton1, filterButton2, filterButton3, filterButton4, filterButton5, filterButton6, filterButton7, filterButton8]
    
    @IBOutlet var filterView: FilterView!
    @IBOutlet var touchMeView: TouchMeView!
    
    var gridView: GridView!
    
    var filters: [EQFilterPrtc] = []
    
    var taskManager = TaskList()
    
    var bthDataSender = BluetoothDataSender()
    var bluetoothVC: BluetoothVC?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initBandSwitchColor()
        initFilterButtonOptions()
        initFilterViewAndTouchMeView()
        initParameterViews()
        initGridView()
        initModelsWithFactoryPreset()
        initBluetoothVC()
    }
    
    private let typeStringDict: [FilterType : String] = [
        .peak: "Peak",
        .lowPass: "LowPass",
        .highPass: "HighPass",
        .lowShelf: "LowShelf",
        .highShelf: "HighShelf"
    ]
    let typeStringArray = ["Peak", "LowPass", "HighPass", "LowShelf", "HighShelf"]

    let numberTypeDict: [Int : FilterType] = [
        0: .peak,
        1: .lowPass,
        2: .highPass,
        3: .lowShelf,
        4: .highShelf
    ]
    
    
    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
        let section = sender.selectedSegmentIndex
        touchMeView.setSectionActive(section)
        filterView.setActiveSection(section)
        let isSection1Selected = section == 0
        pViewSection1.isHidden = !isSection1Selected
        pViewSection2.isHidden = isSection1Selected
    }
    
    @IBAction func filterOnOffSwitch(_ sender: UISwitch) {
        let index = sender.tag
        let tf = sender.isOn
        globalBands[index].isOn = tf
        bthDataSender.sendOnOffData(at: index, isOn: tf)
        parameterViewArray[index].setViewActive(tf)
        touchMeView.setDotActive(index, isActive: tf)
        filterButtons[index]?.isEnabled = tf
        if !tf { allResponses[index].setResponseDefault() }
        else { filters[index].updateResponse() }
        filterView.masterGraphUpdate()
    }
    
    @IBAction func bluetoothButtonPushed(_ sender: UIButton) {
        guard let vc = bluetoothVC else { return }
        self.present(vc, animated: true)
    }
    
    @IBAction func undo(_ sender: UIButton) {
        let index = taskManager.undo()
        guard let index = index else { return }
        if index == -1 {
            setByPreset()
        } else {
            setBandByPreset(index)
            filterView.masterGraphUpdate()
        }
    }
    
    @IBAction func redo(_ sender: UIButton) {
        let index = taskManager.redo()
        guard let index = index else { return }
        if index == -1 {
            setByPreset()
        } else {
            setBandByPreset(index)
            filterView.masterGraphUpdate()
        }
    }
}


extension MainViewController { //initializers
    
    private func initBandSwitchColor() {
        for (i, switch_) in bandSwitches.enumerated(){
            switch_?.onTintColor = colorDict[i]
        }
    }
    private func initFilterButtonOptions() {
        // and sets the actions for each option in the menu.
        for (i, button) in filterButtons.enumerated() {
            var optionsArray: [UIAction] = []
            for (filterIndex, title) in typeStringArray.enumerated() {
                let option = UIAction(title: title, handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.changeInFilterType(index: i, type: numberTypeDict[filterIndex]!)
                })
                optionsArray.append(option)
            }
            let menu = UIMenu(title: "Filter Types", options: .displayInline, children: optionsArray)
            button!.menu = menu
            button!.tintColor = colorDict[i]
            setFilterMenuSelection(i, defaultFilterType[i])
        }
    }
    
    private func initParameterViews() {
        for (i, band) in factoryPreset.bands.enumerated() {
            let view = loadPViewFromXib(i, band.type)
            view.tintColor = colorDict[i]
            view.backgroundColor = .clear
            parameterViewArray.append(view)
        }
        pViewSection2.isHidden = true
    }
    
    private func initFilterViewAndTouchMeView() {
        touchMeView.delegate = self
        touchMeView.initializeDots()
        touchMeView.setSectionActive(0)
    }
    
    private func initGridView() {
        gridView = GridView(frame: view.frame, standard: filterView.bounds)
        filterView.addSubview(gridView)
        filterView.sendSubviewToBack(gridView)
    }
    
    private func initModelsWithFactoryPreset() {
        combinedResponse.setTree(allResponses, nil)
        for (i, band) in globalBands.enumerated() {
            filters.append(Peak(i))
            setOneFilter(band, i)
        }
    }
    
    private func initBluetoothVC() {
        let storyboard = UIStoryboard(name: "ToolBarVC", bundle: nil)
        guard let bluetoothVC = storyboard.instantiateViewController(withIdentifier: "BluetoothVC") as? BluetoothVC else {
            print("instantiate bluetoothVC Failed"); return }
        bluetoothVC.modalPresentationStyle = .formSheet
        bluetoothVC.delegate = self
        self.bluetoothVC = bluetoothVC
    }
}


extension MainViewController: PViewDelegate, TouchMeViewDelegate {
    
    func pViewSliderMoved(_ index: Int, _ value: Double) {
        globalBands[index].setZ(value)
        bthDataSender.sendZdata(at: index, z: value)
        let filter = filters[index]
        filter.setZ()
        filter.updateResponse()
        filterView.responseDidUpdate(at: index)
        filterView.masterGraphUpdate()
    }
    
    func pViewSliderTouchBegin(_ index: Int) {
        pendingTaskBand = globalBands[index].copy() as! OneBand
    }
    
    func pViewSliderTouchEnded(_ index: Int) {
        let zValue = globalBands[index].getZ()
        bthDataSender.sendZdata(at: index, z: zValue, interval: false)
        taskManager.listAppend(index)
    }
    
    func pViewMenuChanged(_ type: Slope) {
        
    }
    
    func dotDidMove(_ index: Int, _ position: XYPosition) {
        globalBands[index].setXY(position)
        bthDataSender.sendXYdata(at: index, xy: position)
        let filter = filters[index]
        filter.setX()
        filter.setY()
        filter.updateResponse()
        filterView.responseDidUpdate(at: index)
        filterView.masterGraphUpdate()
    }
    
    func touchesBegin(_ index: Int) {
        pendingTaskBand = globalBands[index].copy() as! OneBand
    }
    
    func touchesEnded(_ index: Int) {
        let position = globalBands[index].getXY()
        bthDataSender.sendXYdata(at: index, xy: position, interval: false)
        taskManager.listAppend(index)
    }
    
}

extension MainViewController {
    // typeParameter의 변화에 따라서 사용될 함수들
    private func changeInFilterType(index: Int, type: FilterType) {
        let band = globalBands[index]
        pendingTaskBand = band.copy() as! OneBand
        band.type = type
        taskManager.listAppend(index)
        bthDataSender.sendBandData(at: index, band: band)
        setPViewWithPreset(index, type, band.getZ())
        setOneFilter(band, index)
        filterView.responseDidUpdate(at: index)
        filterView.masterGraphUpdate()
    }
    
    private func setBandByPreset(_ index: Int) {
        let band = globalBands[index]
        bthDataSender.sendBandData(at: index, band: band)
        setFilterMenuSelection(index, band.type)
        setPViewWithPreset(index, band.type, band.getZ())
        touchMeView.setDotByPreset(index: index, value: band.getXY())
        setOneFilter(band, index)
        filterView.responseDidUpdate(at: index)
    }

    private func setByPreset() {
        for i in 0..<globalBands.count {
            setBandByPreset(i)
        }
        filterView.masterGraphUpdate()
    }
    
    private func setPViewWithPreset(_ index: Int, _ type: FilterType, _ z: Double) {
        parameterViewArray[index].removeFromSuperview()
        let newView = loadPViewFromXib(index, type)
        parameterViewArray[index] = newView
        newView.setSliderByPreset(z)
    }
    
    private func setOneFilter(_ band: OneBand, _ index: Int) {
        var filter: EQFilterPrtc
        switch band.type {
        case .peak:
            filter = Peak(index)
        case .lowPass:
            filter = LowPass(index)
        case .highPass:
            filter = HighPass(index)
        case .lowShelf:
            filter = LowShelf(index)
        case .highShelf:
            filter = HighShelf(index)
        }
        filters[index] = filter
    }
    
    private func loadPViewFromXib(_ index: Int, _ type: FilterType) -> ParameterView {
        if let view = Bundle.main.loadNibNamed(typePViewDict[type]!, owner: nil)?.first as? ParameterView {
            view.frame = paramViews_[index]!.bounds
            view.index = index
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.delegate = self
            view.tintColor = colorDict[index]
            paramViews_[index]!.addSubview(view)
            paramViews_[index]!.bringSubviewToFront(view)
            return view
        } else { fatalError() }
    }
    
    private func setFilterMenuSelection(_ index: Int, _ type: FilterType) {
        guard let typeString = typeStringDict[type] else {return}
        guard let button = filterButtons[index] else {return}
        button.setTitle(typeString, for: .normal)
        button.menu?.children.forEach { action in
            guard let action_ = action as? UIAction else {return}
            if action_.title == typeString {
                action_.state = .on
            } else {
                action_.state = .off
            }
        }
    }
}

extension MainViewController: BluetoothVCDelegate {
    func bluetoothConnected(serial: BluetoothSerial) {
        self.bthDataSender.serial = serial
        self.bthDataSender.resetAllData(preset: globalBands)
    }
    
    func btWriteFailed() {
        
    }
}

