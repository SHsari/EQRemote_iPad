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
    
    var activePView: ParameterView = PView_withSlider()
    
    //var taskManager = TaskList()
    var pendingTaskBand = OneBand()
    var pendingTaskPreset = factoryPreset_()
    
    var bthDataSender = BluetoothDataSender()
    var bluetoothVC: BluetoothVC?

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        for band in factoryPreset_().bands {
            storages.append(band)
            let bind = band.position
            let norm = XYZPosition()
            self.norm.append(norm)
            self.bind.append(bind)
        }
        filterManager.initialize(storage: storages, norm: norm)
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
        for (i, band) in storages.enumerated() {
            let type = band.type
            let view = pViewDict[type]!()
            view.tintColor = colorDict[i]
            view.backgroundColor = .clear
            parameterViews.append(view)
            paramViews_[i]?.addSubview(view)
            view.setLayoutWithSuperView()
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
        touchMeView.initialize(normPositions: norm)
        filterManager.setFilterView(view: filterView)
    }
    
    private func initGridView() {
        gridView = GridView(frame: view.frame, standard: filterView.bounds)
        filterView.addSubview(gridView)
        filterView.sendSubviewToBack(gridView)
    }
}


extension MainViewController: PViewDelegate {
    
    func sliderMoved(_ value: Double) { filterManager.sliderMoved(value) }
    
    func sliderTouchesBegan(_ index: Int) { filterManager.touchesBegan(at: index) }
    
    func sliderTouchesEnded() { }
    
    func xLocktoggled(at index: Int) { touchMeView.xLockToggled(at: index) }
    func yLocktoggled(at index: Int) { touchMeView.yLockToggled(at: index) }

    
    func didDoubleTap_freq(at index: Int) {
        let x = factoryPreset_().bands[index].position.x
        filterManager.set(normX: x, at: index)
        touchMeView.doubleTapped(at: index, with: XYPosition(x: x, y: norm[index].y))
    }
    
    func didDoubleTap_gain(at index: Int) {
        let y = factoryPreset_().bands[index].position.y
        filterManager.set(normY: y, at: index)
        touchMeView.doubleTapped(at: index, with: norm[index].getXY())
    }
    
    func didDoubleTap_Q(at index: Int) {
        let z = factoryPreset_().bands[index].position.z
        filterManager.set(normZ: z, at: index)
        parameterViews[index].updateSlider(z)
    }
    
    
    func copyRequest(at index: Int, pType: ParameterType) {
        switch pType {
        case .x: Clipboard.data = norm[index].x
        case .y: Clipboard.data = norm[index].y
        case .z: Clipboard.data = norm[index].z
        case .band: Clipboard.data = norm[index].copy()
        case .dot: Clipboard.data = norm[index].getXY()
        }
    }
    
    func pasteRequest(at index: Int) {
        guard let pType = Clipboard.type else { return }
        switch pType {
        case .x:
            guard let x = Clipboard.data as? Double else {return}
            filterManager.set(normX: x, at: index)
            parameterViews[index].updateXLabel()
            touchMeView.setXwith(value: x, at: index)
        case .y:
            guard let y = Clipboard.data as? Double else {return}
            filterManager.set(normY: y, at: index)
            parameterViews[index].updateYLabel()
            touchMeView.setYwith(value: y, at: index)
        case .z:
            guard let z = Clipboard.data as? Double else {return}
            filterManager.set(normZ: z, at: index)
            parameterViews[index].updateZLabel()
            parameterViews[index].updateSlider(z)
        case .band:
            guard let band = Clipboard.data as? XYZPosition else {return}
            filterManager.set(band: band, at: index)
            parameterViews[index].updateWhole(band.z)
            touchMeView.setPositionByPreset(at: index, with: band.getXY())
        case .dot: //Touch Me View에서 아직 구현안됨.
            guard let position = Clipboard.data as? XYPosition else {return}
            filterManager.touchesBegan(at: index)
            filterManager.touchesMoved(position)
            parameterViews[index].updateXLabel()
            parameterViews[index].updateYLabel()
            touchMeView.setPositionByPreset(at: index, with: position)
        }
    }
    
    func typeInRequest(at index: Int, type: ParameterType) {
        
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
        filterManager.touchesBegan(at: index)
    }
    
    func touchesEnded() {}
    
    func didDoubleTap(at index: Int)  {
        activePView = parameterViews[index]
        filterManager.touchesBegan(at: index)
    }
    func pasteResquest(at index: Int) {
        self.pasteRequest(at: index)
    }
}

extension MainViewController {
    
    // typeParameter의 변화에 따라서 사용될 함수들
    private func changeInFilterType(index: Int, type: FilterType) {
        filterManager.filterTypeChanged(at: index, type: type)
        changePview(at: index, type: type)
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
    func changePview(at index: Int, type: FilterType) {
        parameterViews[index].removeFromSuperview()
        let newView = pViewDict[type]!()
        parameterViews[index] = newView
        paramViews_[index]?.addSubview(newView)
        newView.setLayoutWithSuperView()
        newView.initialize(bind[index], index, self)
        newView.tintColor = colorDict[index]
        newView.updateXLabel()
        newView.updateYLabel()
        newView.updateZLabel()
        newView.updateSlider(norm[index].z)
    }
    
    
    
    /*
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
    */
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

