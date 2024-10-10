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
    
    private var filters: [EQFilterPrtc] = []
    
    private var bind: [XYZPosition] = []
    private var norm: [XYZPosition] = []
    var storages: [OneBand] = []
    
    var activePView: ParameterView = PView_peak()
    
    var taskManager: TaskList
    
    var bthDataSender = BluetoothDataSender()
    var bluetoothVC: BluetoothVC?
    
    var pendingTask: Recordable = factoryPreset_()
    var taskIndex: Int = -1

    
    required init?(coder: NSCoder) {
        
        for band in factoryPreset_().bands {
            storages.append(band)
            let bind = band.position
            let norm = XYZPosition()
            self.norm.append(norm)
            self.bind.append(bind)
        }
        filterManager.initialize(storage: storages, norm: norm)
        taskManager = TaskList(storage: storages, bind: bind)
        
        super.init(coder: coder)
        taskManager.delegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initBandSwitchColor()
        initTypeMenuOptions()
        
        initFilterViewAndTouchMeView()
        initParameterViews()
        initGridView()
    }
    

    let typeStringArray = ["Peak", "LowPass", "HighPass", "LowShelf", "HighShelf"]
    
    let numberTypeDict: [Int : FilterType] = [
        0: .peak,
        1: .lowPass,
        2: .highPass,
        3: .lowShelf,
        4: .highShelf
    ]
    
    @IBOutlet weak var undoBTN: UIButton!
    @IBOutlet weak var redoBTN: UIButton!
    @IBAction func undo(_ sender: UIButton) { taskManager.undo() }
    @IBAction func redo(_ sender: UIButton) { taskManager.redo() }
    
    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
        let section = sender.selectedSegmentIndex
        sectionChange(section)
    }
    func sectionChange(_ section: Int) {
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
            view.updateSlider()
        }
        pViewSection2.isHidden = true
    }
    
    private func initFilterViewAndTouchMeView() {
        touchMeView.delegate = self
        touchMeView.initialize(bindPositions: bind)
        filterManager.setFilterView(view: filterView)
    }
    
    private func initGridView() {
        gridView = GridView(frame: view.frame, standard: filterView.bounds)
        filterView.addSubview(gridView)
        filterView.sendSubviewToBack(gridView)
    }
}


extension MainViewController: PViewDelegate {
   
    func sliderTouchesBegan(_ index: Int) {
        taskManager.sliderWillMove(at: index)
        filterManager.willBeChange(in: index)
    }
    func sliderMoved(_ value: Double) { filterManager.sliderMoved(value) }
    func sliderTouchesEnded() {
        taskManager.sliderDidMove()
    }
    
    func xLocktoggled(at index: Int) { touchMeView.xLockToggled(at: index) }
    func yLocktoggled(at index: Int) { touchMeView.yLockToggled(at: index) }
    
    func didDoubleTap_freq(at index: Int) {
        let x = factoryPreset_().bands[index].position.x
        filterManager.set(bindX: x, at: index)
        touchMeView.doubleTapped(at: index, with: XYPosition(x: x, y: bind[index].y))
        taskManager.dotDidMove()
    }
    
    func didDoubleTap_gain(at index: Int) {
        let y = factoryPreset_().bands[index].position.y
        filterManager.set(bindY: y, at: index)
        touchMeView.doubleTapped(at: index, with: bind[index].getXY())
        taskManager.dotDidMove()
    }
    
    func didDoubleTap_Q(at index: Int) {
        let z = factoryPreset_().bands[index].position.z
        filterManager.set(bindZ: z, at: index)
        parameterViews[index].updateSlider()
        taskManager.sliderDidMove()
    }
    
    func copyRequest(at index: Int, pType: ParameterType) {
        switch pType {
        case .x: Clipboard.data = bind[index].x
        case .y: Clipboard.data = bind[index].y
        case .z: Clipboard.data = norm[index].z
        case .band: Clipboard.data = bind[index].copy()
        case .dot: Clipboard.data = bind[index].getXY()
        }
    }
    
    func pasteRequest(at index: Int) {
        guard let pType = Clipboard.type else { return }
        taskManager.xyzWillChange(at: index)
        switch pType {
        case .x:
            guard let x = Clipboard.data as? Double else {return}
            filterManager.set(bindX: x, at: index)
            parameterViews[index].updateXLabel()
            touchMeView.setXwith(value: x, at: index)
        case .y:
            guard let y = Clipboard.data as? Double else {return}
            filterManager.set(bindY: y, at: index)
            parameterViews[index].updateYLabel()
            touchMeView.setYwith(value: y, at: index)
        case .z:
            guard let z = Clipboard.data as? Double else {return}
            filterManager.set(normZ: z, at: index)
            parameterViews[index].updateZLabel()
            parameterViews[index].updateSlider()
        case .band:
            guard let band = Clipboard.data as? XYZPosition else {return}
            filterManager.set(xyz: band, at: index)
            parameterViews[index].updateWhole()
            touchMeView.setPositionDirect(at: index, with: band.getXY())
        case .dot: //Touch Me View에서 아직 구현안됨.
            guard let position = Clipboard.data as? XYPosition else {return}
            filterManager.willBeChange(in: index)
            filterManager.touchesMoved(position)
            parameterViews[index].updateXLabel()
            parameterViews[index].updateYLabel()
            touchMeView.setPositionDirect(at: index, with: position)
        }
        taskManager.xyzDidChange()
    }
    
    func typeInRequest(at index: Int, type: ParameterType) {
        //guard let view = Bundle.main.loadNibNamed("TypeInVC", owner: nil)?.first else {return}
        let typeInVC = TypeInVC(nibName: "TypeInVC", bundle: nil)
        typeInVC.modalPresentationStyle = .formSheet
        typeInVC.modalTransitionStyle = .crossDissolve
        present(typeInVC, animated: true, completion: nil)
        typeInVC.initialize(index: index, band: storages[index], delegate: self)
    }
    
}
    
extension MainViewController: TypeInVCDelegate {
    func vcDismissed(at index: Int, _ values: [Double?]) {
        taskManager.xyzWillChange(at: index)
        let xyz = bind[index].copy()
        if let x = values[0] { xyz.x = x }
        if let y = values[1] { xyz.y = y }
        if let z = values[2] { xyz.z = z }
        filterManager.set(xyz: xyz, at: index)
        touchMeView.setPositionDirect(at: index, with: xyz.getXY())
        parameterViews[index].updateWhole()
        taskManager.xyzDidChange()
    }
}



extension MainViewController: TouchMeViewDelegate {
    
    func touchesBegan(_ index: Int) {
        activePView = parameterViews[index]
        filterManager.willBeChange(in: index)
        taskManager.dotWillMove(at: index)
    }
    
    func touchesMoved(_ position: XYPosition) {
        filterManager.touchesMoved(position)
        activePView.updateXLabel()
        activePView.updateYLabel()
    }
    
    func touchesEnded() {
        taskManager.dotDidMove()
    }
    
    func didDoubleTap(at index: Int)  {
        activePView = parameterViews[index]
        filterManager.willBeChange(in: index)
        taskManager.dotWillMove(at: index)
    }
    
}

extension MainViewController {
    
    // typeParameter의 변화에 따라서 사용될 함수들
    private func changeInFilterType(index: Int, type: FilterType) {
        taskManager.bandWillChange(at: index)
        storages[index].type = type
        filterManager.filterTypeChanged(at: index, type: type)
        changePview(at: index, type: type)
        touchMeView.resetDotLock(at: index)
        taskManager.bandDidChange()
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
        newView.updateSlider()
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

extension MainViewController: TaskListDelegate {
    
    func setRedoEnable(_ isEnable: Bool) { redoBTN.isEnabled = isEnable }
    func setUndoEnable(_ isEnable: Bool) { undoBTN.isEnabled = isEnable }
    
    func willChangeByTask(at index: Int) {
        let taskSection = index/4
        if sectionController.selectedSegmentIndex != taskSection {
            sectionController.selectedSegmentIndex = taskSection
            sectionChange(taskSection)
        }
    }
    
    func setZ(value: Double, at index: Int) {
        filterManager.set(bindZ: value, at: index)
        parameterViews[index].updateSlider()
    }
    
    func setDot(value: XYPosition, at index: Int) {
        filterManager.willBeChange(in: index)
        filterManager.touchesMoved(value)
        parameterViews[index].updateXLabel()
        parameterViews[index].updateYLabel()
        touchMeView.setPositionDirect(at: index, with: value)
    }
    
    func setXYZ(value: XYZPosition, at index: Int) {
        let xy = value.getXY()
        filterManager.willBeChange(in: index)
        filterManager.set(xyz: value, at: index)
        parameterViews[index].updateWhole()
        touchMeView.setPositionDirect(at: index, with: xy)
    }
    
    func setBand(value: OneBand, at index: Int) {
        let type = value.type
        storages[index].type = type
        filterManager.setBand(band: value, at: index)
        changePview(at: index, type: type)
        parameterViews[index].updateWhole()
        setFilterMenuSelection(index, type)
        touchMeView.resetDotLock(at: index)
        touchMeView.setPositionDirect(at: index, with: value.getXY())
    }
    
    func setPreset(preset: Preset) {
        let bands = preset.bands
        var sectionOffset = 0
        if bands.count == 4 {
            getSectionFromAlert { section in
            sectionOffset = section * 4
            }
        }
        else if bands.count == 8 {
        } else { return }
        for (i, band) in bands.enumerated() {
            let index = i + sectionOffset
            setBand(value: band, at: index)
        }
    }
    
    private func getSectionFromAlert(completion: @escaping (Int) -> Void) {

        let alertController = UIAlertController(title: "Select Section", message: "Choose a section", preferredStyle: .actionSheet)

        let section0Action = UIAlertAction(title: "Section 0", style: .default) { _ in
            completion(0)
        }

        let section1Action = UIAlertAction(title: "Section 1", style: .default) { _ in
            completion(1)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(section0Action)
        alertController.addAction(section1Action)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
