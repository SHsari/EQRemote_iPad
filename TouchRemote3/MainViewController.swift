//
//  ViewController.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var sectionController: UISegmentedControl!
    
    @IBOutlet weak var pViewSection1: UIView!
    @IBOutlet weak var pViewSection2: UIView!
    
    @IBOutlet var pView1: UIView!
    @IBOutlet var pView2: UIView!
    @IBOutlet var pView3: UIView!
    @IBOutlet var pView4: UIView!
    @IBOutlet var pView5: UIView!
    @IBOutlet var pView6: UIView!
    @IBOutlet var pView7: UIView!
    @IBOutlet var pView8: UIView!
    
    private lazy var paramViews_ = [pView1, pView2, pView3, pView4, pView5, pView6, pView7, pView8]
    private var parameterViews: [ParameterView] = []
    
    @IBOutlet weak var onOffSwitch1: UISwitch!
    @IBOutlet weak var onOffSwitch2: UISwitch!
    @IBOutlet weak var onOffSwitch3: UISwitch!
    @IBOutlet weak var onOffSwitch4: UISwitch!
    @IBOutlet weak var onOffSwitch5: UISwitch!
    @IBOutlet weak var onOffSwitch6: UISwitch!
    @IBOutlet weak var onOffSwitch7: UISwitch!
    @IBOutlet weak var onOffSwitch8: UISwitch!
    
    private lazy var bandSwitches = [onOffSwitch1, onOffSwitch2, onOffSwitch3, onOffSwitch4, onOffSwitch5, onOffSwitch6, onOffSwitch7, onOffSwitch8]
    
    @IBOutlet var typeMenu1: UIButton!
    @IBOutlet var typeMenu2: UIButton!
    @IBOutlet var typeMenu3: UIButton!
    @IBOutlet var typeMenu4: UIButton!
    @IBOutlet var typeMenu5: UIButton!
    @IBOutlet var typeMenu6: UIButton!
    @IBOutlet var typeMenu7: UIButton!
    @IBOutlet var typeMenu8: UIButton!
    
    lazy var typeMenu = [typeMenu1, typeMenu2, typeMenu3, typeMenu4, typeMenu5, typeMenu6, typeMenu7, typeMenu8]
    
    @IBOutlet var filterView: FilterView!
    @IBOutlet var touchMeView: TouchMeView!
    var gridView: GridView!
    
    var filterManager = FilterManager()
    private var bind: [XYZPosition] = []
    private var norm: [XYZPosition] = []
    var storages: [OneBand] = []
    
    var activePView: ParameterView = PView_noSlider()
    
    //var taskManager = TaskList()
    var pendingTaskBand = OneBand()
    var pendingTaskPreset = factoryPreset_()
    
    var bthDataSender = BluetoothDataSender()
    var bluetoothVC: BluetoothVC?

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        for band in factoryPreset_().bands {
            storages.append(band)
            let norm = band.position
            let bind = XYZPosition()
            self.norm.append(norm)
            self.bind.append(bind)
        }
        filterManager.initialize(storage: storages, bind: bind)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initBandSwitchColor()
        initTypeMenuOptions()
        initModels()
        
        initFilterViewAndTouchMeView()
        initParameterViews()
        initGridView()
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
        filterView.setSectionActive(section)
        let isSection1Selected = section == 0
        pViewSection1.isHidden = !isSection1Selected
        pViewSection2.isHidden = isSection1Selected
    }
    
    @IBAction func filterOnOffSwitch(_ sender: UISwitch) {
        let index = sender.tag
        let isOn = sender.isOn
        storages[index].isOn = isOn
        parameterViews[index].setViewActive(isOn)
        touchMeView.setDotActive(index, isActive: isOn)
        typeMenu[index]?.isEnabled = isOn
        filterManager.handleOnOff(at: index, isOn: isOn)
        filterView.masterGraphUpdate()
    }
}

extension MainViewController { //initializers
    private func initBandSwitchColor() {
        for (i, switch_) in bandSwitches.enumerated(){
            switch_?.onTintColor = colorDict[i]
        }
    }
    private func initTypeMenuOptions() {
        // and sets the actions for each option in the menu.
        for (i, button) in typeMenu.enumerated() {
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
    
    private func initModels() {

    }
    
    private func initParameterViews() {
        for (i, band) in factoryPreset.bands.enumerated() {
            let view = loadPViewFromXib(i, band.type)
            view.tintColor = colorDict[i]
            view.backgroundColor = .clear
            parameterViews.append(view)
            view.initialize(bind[i], i, self)
            view.updateXLabel()
            view.updateYLabel()
            view.updateZLabel()
            view.updateSlider(norm[i].z)
        }
        pViewSection2.isHidden = true
    }
    
    private func initFilterViewAndTouchMeView() {
        touchMeView.delegate = self
        touchMeView.initialize()
        filterManager.setFilterView(view: filterView)
    }
    
    private func initGridView() {
        gridView = GridView(frame: view.frame, standard: filterView.bounds)
        filterView.addSubview(gridView)
        filterView.sendSubviewToBack(gridView)
    }
}


extension MainViewController: PViewDelegate {
    
    
    func sliderMoved(_ value: Double) {
        filterManager.sliderMoved(value)
    }
    
    func sliderTouchesBegan(_ index: Int) {
        filterManager.changesBegan(index)
    }
    
    func sliderTouchesEnded() {
    }
    
    func xLocktoggled(at index: Int) {
        touchMeView.xLockToggled(at: index)
    }
    func yLocktoggled(at index: Int) {
        touchMeView.yLockToggled(at: index)
    }

}

extension MainViewController: TouchMeViewDelegate {
    func touchesMoved(_ position: XYPosition) {
        filterManager.touchesMoved(position)
        activePView.updateXLabel()
        activePView.updateYLabel()
    }
    
    func touchesBegan(_ index: Int) {
        activePView = parameterViews[index]
        filterManager.changesBegan(index)
    }
    
    func touchesEnded() {
    }
}

extension MainViewController {
    
    // typeParameter의 변화에 따라서 사용될 함수들
    private func changeInFilterType(index: Int, type: FilterType) {
        filterManager.filterTypeChanged(at: index, type: type)
        changePview(at: index, type: type)
        touchMeView.
    }
    /*
    private func setBandByPreset(_ index: Int) {
        setFilterMenuSelection(index, band.type)
        setPViewWithPreset(index, band.type, 0.5)
        touchMeView.setDotByPreset(index: index, value: band.getXY())
        filterView.responseDidUpdate()
    }

    private func setByPreset() {
        for i in 0..<bands.count {
            setBandByPreset(i)
        }
        filterView.masterGraphUpdate()
    }*/
    
    func setRootResponse() {

    }
    
    private func changePview(at index: Int, type: FilterType) {
        parameterViews[index].removeFromSuperview()
        let newView = loadPViewFromXib(index, type)
        parameterViews[index] = newView
        newView.initialize(bind[index], index, self)
        newView.updateXLabel()
        newView.updateYLabel()
        newView.updateZLabel()
        newView.updateSlider(norm[index].z)
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
        guard let button = typeMenu[index] else {return}
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
        self.bthDataSender.resetAllData(preset: storages)
    }
    
    func btWriteFailed() {
        
    }
}

