//
//  ViewController.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import UIKit

// 이걸 다시보니 바보같은 면이 많이 보이네요.
class MainViewController: UIViewController {
    
    //섹션 1과 섹션 2가 존재합니다. 이는 한 화면에 4개 이상의 밴드를 표시하기 어려워서 나눈 것 입니다.
    // 즉, 총 8개의 밴드가 존재합니다.
    @IBOutlet weak var sectionController: UISegmentedControl!
    
    // 화면 하단에 표시되는 parameterView도 2개로 선언되었습니다.
    // 섹션이 바뀔 때 마다 하나는 표시되고 하나는 disable 됩니다.
    @IBOutlet weak var pViewSection1: UIView!
    @IBOutlet weak var pViewSection2: UIView!
    
    // 밴드별 parameter View
    @IBOutlet var pView1: UIView!
    @IBOutlet var pView2: UIView!
    @IBOutlet var pView3: UIView!
    @IBOutlet var pView4: UIView!
    @IBOutlet var pView5: UIView!
    @IBOutlet var pView6: UIView!
    @IBOutlet var pView7: UIView!
    @IBOutlet var pView8: UIView!
    
    // 인덱스로 접근하기 위한 Parameter View 리스트입니다.
    private lazy var paramViews_ = [pView1, pView2, pView3, pView4, pView5, pView6, pView7, pView8]
    private var parameterViews: [ParameterView] = []
    
    // 밴드별로 EQ를 켜거나 끌 수 잇습니다. 스위치이며 역시 인덱스로 접근하기 위해 아래 배열로 선언햇씁니다.
    @IBOutlet weak var onOffSwitch1: UISwitch!
    @IBOutlet weak var onOffSwitch2: UISwitch!
    @IBOutlet weak var onOffSwitch3: UISwitch!
    @IBOutlet weak var onOffSwitch4: UISwitch!
    @IBOutlet weak var onOffSwitch5: UISwitch!
    @IBOutlet weak var onOffSwitch6: UISwitch!
    @IBOutlet weak var onOffSwitch7: UISwitch!
    @IBOutlet weak var onOffSwitch8: UISwitch!
    
    private lazy var bandSwitches = [onOffSwitch1, onOffSwitch2, onOffSwitch3, onOffSwitch4, onOffSwitch5, onOffSwitch6, onOffSwitch7, onOffSwitch8]
    
    
    // 밴드별로 어떤 전달함 수를 사용할 것인지
    // 즉, 어떤 타입의 EQ 필터를 사용할 것인지 설정하는 Menu들 입니다.
    @IBOutlet var typeMenu1: UIButton!
    @IBOutlet var typeMenu2: UIButton!
    @IBOutlet var typeMenu3: UIButton!
    @IBOutlet var typeMenu4: UIButton!
    @IBOutlet var typeMenu5: UIButton!
    @IBOutlet var typeMenu6: UIButton!
    @IBOutlet var typeMenu7: UIButton!
    @IBOutlet var typeMenu8: UIButton!
    
    lazy var typeMenu = [typeMenu1, typeMenu2, typeMenu3, typeMenu4, typeMenu5, typeMenu6, typeMenu7, typeMenu8]
    
    // 그래프를 표시해주는 중심 창인 filter View
    @IBOutlet var filterView: FilterView!
    // filterView 위에 표시되는 touchMeView.
    // 밴드의 Frequency값과 gain을 터치가 이뤄진 x,y 좌표로 부터 설정합니다.
    // 위의 내용을 처리하는 View, TouchMeView 입니다.
    @IBOutlet var touchMeView: TouchMeView!
    // 이큐의 그리드를 표시해주는 배경, 그리드뷰.
    var gridView: GridView!
    
    // Model 부분이라 할 수 있습니다. 그래프를 표시하기 위해
    // 전달함수의 Frequency에 따른 gain 값을 계산해줍니다.
    // 내부적으로 8개의 밴드가 동작하며 밴드 하나를 위해 2048개의 점에 대해 계산을 진행합니다.
    // 이거 뭔가.. 실수했나.? 비효율적인 알고리즘을 사용하나..?
    var filterManager = FilterManager()
    
    private var filters: [EQFilterPrtc] = []
    
    // 각 밴드별로 Type이 일단 정해지면,
    // 중심주파수, Gain(dB), 그리고 Q값 이렇게 3가지 Double 값이 정해지면
    // 필터 한개가 완전히 특정됩니다.
    // 중심주파수를 X에, Gain을 Y에, Q값을 Z에 대응했습니다.
    private var bind: [XYZPosition] = []
    private var norm: [XYZPosition] = []
    var storages: [OneBand] = []
    
    // 인덱스를 이용한 접근을 피하기 위해서 activePview라는 것을 선언하여
    // 파라미터 변경이 시작될 때 ActivePView에 변경이 일어나고 있는 pView를 할당해주는데,
    // 아주 바보같은 일인 것 같습니다 지금 생각해보니 아주 개똥같네 정말로
    var activePView: ParameterView = PView_peak()
    
    // Undo와 Redo를 가능하게 해주는 아주 기똥찬 녀석 TaskList 입니다.
    var taskManager: TaskList
    
    //
    var bthDataSender: BluetoothDataSender
    lazy var bluetoothVC = BluetoothVC()
    
    // 터치 이벤트가 시작할때, 기존값을 pendingTask에 기록합니다.
    // 터치 이벤트가 끝나면 수정값과 함께 pendingTask를 Task목록에 기록합니다.
    var pendingTask: Recordable = factoryPreset_()
    var taskIndex: Int = -1
    var alertSection: Int = -1
    var movingIndex: Int?
    
    required init?(coder: NSCoder) {
        // 진짜 Swift 초기화 규칙때문에 머리 터지는 줄 알았습니다. 어휴
        for band in factoryPreset_().bands {
            storages.append(band)
            let bind = band.position
            let norm = XYZPosition()
            self.norm.append(norm)
            self.bind.append(bind)
        }
        filterManager.initialize(storage: storages, norm: norm)
        taskManager = TaskList(storage: storages, bind: bind)
        bthDataSender = BluetoothDataSender(storage: storages, bind: bind)
        super.init(coder: coder)
        taskManager.delegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        undoBTN.isEnabled = false
        redoBTN.isEnabled = false
        
        
        initializeBTVC() // 블루투스 화면 초기화
        initSaveBtn() // 프리셋 저장 버튼 초기화
        initBandSwitchColor() //밴드별로 색깔 붙어야 하죠
        initTypeMenuOptions() //타입 선택 메뉴도 초기화 해줍니다.
        
        //그래프 표시 화면과 터치이벤트 처리화면을 초기화합니다.
        initFilterViewAndTouchMeView()
        
        initParameterViews() //하단 파라미터뷰 초기화
        initGridView() // 배경 그리드 초기화
    }
    

    let typeStringArray = ["Peak", "LowPass", "HighPass", "LowShelf", "HighShelf"]
    
    // 숫자 인덱스를 이용해서 필터 타입에 접근합니다.
    let numberTypeDict: [Int : FilterType] = [
        0: .peak,
        1: .lowPass,
        2: .highPass,
        3: .lowShelf,
        4: .highShelf
    ]
    
    // HW에 물리버튼을 통해서 app에 동기화 요청을 보낼 수 있습니다.
    // 요청이 왔을 시 표시할 라벨입니다.
    @IBOutlet weak var requestHWLabel: UILabel!
    @IBOutlet weak var syncHWBtn: UIButton!
    @IBAction func syncBtnPressed(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.bthDataSender.resetAllData(preset: self.storages)
        }
    }
    
    // 하드웨어에 바이패스 물리버튼도 존재합니다. 눌릴경우 어플리케이션에 표시합니다.
    @IBOutlet weak var bypassLabel: UILabel!
    
    // 블루투스 연결시 표시되는 작은 점입니다
    @IBOutlet weak var bluetoothIndicator: UIView!
    @IBOutlet weak var bthCircleWidth: NSLayoutConstraint!
    lazy var bthCircle = CAShapeLayer()
    
    // 블루투스 연결 표시점 표시
    func setBthCircleActive(_ isActive: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let width = isActive ? 5 : 0
            self?.bthCircleWidth.constant = CGFloat(width)
            UIView.animate(withDuration: 0.3, animations: { self?.view.layoutIfNeeded() })
            self?.bthCircle.isHidden = !isActive
            self?.syncHWBtn.isHidden = !isActive
        }
    }
    
    @IBOutlet weak var undoBTN: UIButton!
    @IBOutlet weak var redoBTN: UIButton!
    @IBAction func undo(_ sender: UIButton) { taskManager.undo() }
    @IBAction func redo(_ sender: UIButton) { taskManager.redo() }
    
    @IBOutlet weak var saveBtn: UIButton!

    // 프리셋 로드 버튼
    @IBAction func load(_ sender: UIButton) {
        presentFileExplorer(mode: .load, savePreset: [])
    }
    
    // 1번, 2번 섹션이 있다 햇습니다. 섹션 변경시 호출되는 함수입니다.
    // 표시되는 밴드가 바뀝니다.
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
    
    @IBAction func bluetoothBtn(_ sender: UIButton) {
        self.present(bluetoothVC, animated: true)
    }
    
    // 각 밴드를 켜고 끄는 스위치가 토글되었을 때 호출되는 함수
    @IBAction func filterOnOffSwitch(_ sender: UISwitch) {
        let index = sender.tag
        let isOn = sender.isOn
        filterOnOff(at: index, isOn: isOn)
        taskManager.OnOffChanged(at: index, to: isOn)
    }
    
    func filterOnOff(at index: Int, isOn: Bool){
        if storages[index].isOn != isOn {
            filterManager.handleOnOff(at: index, isOn: isOn)
            filterView.masterGraphUpdate()
        }
        storages[index].isOn = isOn
        parameterViews[index].setViewActive(isOn)
        touchMeView.setDotActive(index, isActive: isOn)
        typeMenu[index]?.isEnabled = isOn
        bthDataSender.sendOnOffData(at: index, isOn: isOn)
    }
}

// 이니셜라인저 담은 섹션입니다. 섹션 구분하기위해 extension 썼는데 괜찮은 지 모르겠네요
extension MainViewController { //initializers
    //블루투스 연결화면 초기화
    private func initializeBTVC() {
        let storyboard = UIStoryboard(name: "BluetoothVC", bundle: nil)
        if let btVC = storyboard.instantiateViewController(withIdentifier: "BluetoothVC") as? BluetoothVC {
            btVC.modalPresentationStyle = .formSheet
            self.bluetoothVC = btVC
            btVC.delegate = self
        }
        
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 11, width: 7, height: 7)).cgPath
        circle.fillColor = UIColor.systemCyan.cgColor
        circle.lineWidth = 0
        circle.isHidden = true
        bluetoothIndicator.layer.addSublayer(circle)
        bthCircle = circle
    }
    
    private func initTaskBtn() {
       
    }
    
    // 프리셋 저장 버튼 초기화
    private func initSaveBtn() {
        // 현재 표시된 섹션을 저장하는 옵션
        let section = UIAction(title: "Current section", handler: { [weak self] _ in
            guard let self = self else { return }
            let offset = sectionController.selectedSegmentIndex * 4
            let savePreset = Array(storages[offset..<offset+sectionSize])
            presentFileExplorer(mode: .save, savePreset: savePreset)
        })
        
        // 전체 섹션을 저장하는 옵션
        let whole = UIAction(title: "All section", handler: { [weak self] _ in
            guard let self = self else { return }
            let savePreset = storages// 스토리지는 전체 프리셋을 담은 놈입니다.
            // 파일 익스플로러를 저장모드로 표시합니다.
            presentFileExplorer(mode: .save, savePreset: savePreset)
        })
        
        // 두가지 선택지를 이용해서 버튼 클릭시 메뉴 표시
        let optionsArray = [section, whole]
        let menu = UIMenu(title: "Choose Section", options: .displayInline, children: optionsArray)
        saveBtn.menu = menu
    }
    
    // on/off 스위치의 색깔을 초기화합니다. ColorDict는 다른곳에 정의되어 있습니다.
    private func initBandSwitchColor() {
        for (i, switch_) in bandSwitches.enumerated(){
            switch_?.onTintColor = colorDict[i]
        }
    }
    
    // 현재 5개정도의 필터 타입을 지원하는데 밴드별로 필터타입을 결정하는 메뉴를 초기화해줍니다.
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
    
    // x, y, z 즉, 주파수, 게인, Q값을 숫자로 표시해주는 View 입니다.
    // 또 Q값은 중앙 화면 터치로 변경이 불가능하기 때문에 Q값 변경 슬라이더를 포함합니다.
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
        gridView = GridView(frame: filterView.bounds)
        filterView.addSubview(gridView)
        filterView.sendSubviewToBack(gridView)
    }
}

extension MainViewController: PViewDelegate {
    // ParameterView의 Q값 slider 변경시
    func sliderTouchesBegan(_ index: Int) {
        self.movingIndex = index
        taskManager.sliderWillMove(at: index)
        filterManager.willBeChange(in: index)
        bthDataSender.willSendData(at: index)
    }
    func sliderMoved(_ value: Double) {
        bthDataSender.sendZdata(z: value)
        filterManager.sliderMoved(value)
    }
    func sliderTouchesEnded(_ index: Int) {
        guard index == movingIndex else { movingIndex = nil; return }
        taskManager.sliderDidMove()
        bthDataSender.sendLastZData()
        movingIndex = nil
    }
    
    // ParameterView에는 주파수를 고정하거나 Gain을 고정하는 기능이 들어있습니다.
    func xLocktoggled(at index: Int) { touchMeView.xLockToggled(at: index) }
    func yLocktoggled(at index: Int) { touchMeView.yLockToggled(at: index) }
    
    // 주파수 표시 라벨을 더블탭 할 경우 기본값으로 초기화합니다.
    func didDoubleTap_freq(at index: Int) {
        taskManager.dotWillMove(at: index)
        let x = factoryPreset_().bands[index].position.x
        filterManager.set(bindX: x, at: index)
        touchMeView.setPositionDirect(at: index, bind: bind[index].getXY())
        taskManager.dotDidMove()
        bthDataSender.sendLastXYData()
    }
    
    // 게인 표시 라벨을 더블 탭 할 경우 기본값으로 초기화됩니다.
    func didDoubleTap_gain(at index: Int) {
        taskManager.dotWillMove(at: index)
        let y = factoryPreset_().bands[index].position.y
        filterManager.set(bindY: y, at: index)
        touchMeView.setPositionDirect(at: index, bind: bind[index].getXY())
        taskManager.dotDidMove()
        bthDataSender.sendLastXYData()
    }
    
    // Q라벨 역시 기본값 초기화 기능이 있습니다.
    func didDoubleTap_Q(at index: Int) {
        taskManager.sliderWillMove(at: index)
        let z = factoryPreset_().bands[index].position.z
        filterManager.set(bindZ: z, at: index)
        parameterViews[index].updateSlider()
        taskManager.sliderDidMove()
        bthDataSender.sendLastZData()
    }
    
    // 밴드나 각 파라미터별로 복사 기능을 구현했습니다.
    // 복사 요청이 온 파라미터 타입에 따라 동작이 구분되어 있습니다.
    func copyRequest(at index: Int, pType: ParameterType) {
        switch pType {
        case .x: Clipboard.data = norm[index].x
        case .y: Clipboard.data = norm[index].y
        case .z: Clipboard.data = norm[index].z
        case .band: Clipboard.data = norm[index].copy()
        case .dot: Clipboard.data = norm[index].getXY()
        }
    }
    // 붙여넣기도 당연히 있겠죠
    // 역시 붙여넣는 파라미터 타입에 따라 동작이 구분됩니다.
    func pasteRequest(at index: Int) {
        guard let pType = Clipboard.type else { return }
        taskManager.xyzWillChange(at: index)
        switch pType {
        case .x:
            guard let x = Clipboard.data as? Double else {return}
            filterManager.set(normX: x, at: index)
            parameterViews[index].updateXLabel()
            touchMeView.setXwith(nvalue: x, at: index)
        case .y:
            guard let y = Clipboard.data as? Double else {return}
            filterManager.set(normY: y, at: index)
            parameterViews[index].updateYLabel()
            touchMeView.setYwith(nvalue: y, at: index)
        case .z:
            guard let z = Clipboard.data as? Double else {return}
            filterManager.set(normZ: z, at: index)
            parameterViews[index].updateZLabel()
            parameterViews[index].updateSlider()
        case .band:
            guard let band = Clipboard.data as? XYZPosition else {return}
            filterManager.setNorm(xyz: band, at: index)
            parameterViews[index].updateWhole()
            touchMeView.setPositionDirect(at: index, norm: band.getXY())
        case .dot: //Touch Me View에서 아직 구현안됨.
            guard let position = Clipboard.data as? XYPosition else {return}
            filterManager.willBeChange(in: index)
            filterManager.touchesMoved(position)
            parameterViews[index].updateXLabel()
            parameterViews[index].updateYLabel()
            touchMeView.setPositionDirect(at: index, norm: position)
        }
        taskManager.xyzDidChange()
        bthDataSender.sendBandData(at: index, band: storages[index])
    }
    
    // 타이핑을 통해 직접 값 변경도 가능합니다.
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
    // 파라미터를 직접 타이핑 하는 경우
    // 한 밴드에 대한 타이핑 설정 창을 띄워줍니다.
    //
    func vcDismissed(at index: Int, _ values: [Double?]) {
        taskManager.xyzWillChange(at: index)
        let xyz = bind[index].copy()
        if let x = values[0] { xyz.x = x }
        if let y = values[1] { xyz.y = y }
        if let z = values[2] { xyz.z = z }
        filterManager.setBind(xyz: xyz, at: index)
        touchMeView.setPositionDirect(at: index, bind: xyz.getXY())
        parameterViews[index].updateWhole()
        taskManager.xyzDidChange()
        bthDataSender.sendBandData(at: index, band: storages[index])
    }
}


extension MainViewController: TouchMeViewDelegate {
    // 가장 핵심적인 화면 중앙부 터치를 통한 파라미터 값 변경입니다.
    // 각 밴드의 Frequency, Gain값이 반영된 위치가 점으로 표시됩니다.
    func touchesBegan(_ index: Int) {
        self.movingIndex = index
        activePView = parameterViews[index]
        filterManager.willBeChange(in: index)
        taskManager.dotWillMove(at: index)
        bthDataSender.willSendData(at: index)
    }
    
    func touchesMoved(_ position: XYPosition) {
        filterManager.touchesMoved(position)
        activePView.updateXLabel()
        activePView.updateYLabel()
        bthDataSender.sendXYdata(xy: position)
    }
    
    func touchesEnded(_ index: Int) {
        guard index == movingIndex else { movingIndex = nil; return }
        taskManager.dotDidMove()
        bthDataSender.sendLastXYData()
        movingIndex = nil
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
        bthDataSender.sendBandData(at: index, band: storages[index])
    }
    // 타입 파라미터에 따라서 파라미터 뷰의 형태도 바뀝니다.
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


extension MainViewController: TaskListDelegate {
    
    // 작업관리자,
    // 즉 undo, redo 기능을 관리합니다.
    // 원래는 지금까지 기록된 작업을 TableView로 띄워서 선택할 수 있도록 하려 했는데,
    // 기력이 거기까진 미치지 않더라구요,.
    func setRedoEnable(_ isEnable: Bool) { UIView.performWithoutAnimation { redoBTN.isEnabled = isEnable } }
    func setUndoEnable(_ isEnable: Bool) { UIView.performWithoutAnimation { undoBTN.isEnabled = isEnable } }
    
    // 파라미터 변경시 제가 사용한 바보같은 로직때문에
    // 이런 함수가 추가로 필요해졌습니다.
    func willChangeByTask(at index: Int) {
        let taskSection = index/4
        if sectionController.selectedSegmentIndex != taskSection {
            sectionController.selectedSegmentIndex = taskSection
            sectionChange(taskSection)
        }
        bthDataSender.willSendData(at: index)
    }
    
    // Task의 유형별로 함수가 나누어져 있습니다.
    // 제 성질이면 분명히 Dictionary 같은걸로 함수에 접근했을 겁니다.
    // 아마 그냥 switch Case 쓰는게 오버헤드가 적겠죤..??
    func setOnOff(value: Bool, at index: Int) {
        let tmpSwitch = bandSwitches[index]!
        tmpSwitch.setOn(value, animated: true)
        filterOnOff(at: index, isOn: value)
    }
    
    func setZ(value: Double, at index: Int) {
        filterManager.set(bindZ: value, at: index)
        parameterViews[index].updateSlider()
        bthDataSender.sendLastZData()
    }
    
    // Dot은 X, Y 값에 의해 위치가 결정되니까
    // frequency와 gain값이 변경되는 셈입니다.
    func setDot(value: XYPosition, at index: Int) {
        filterManager.willBeChange(in: index)
        filterManager.touchesMoved(value)
        parameterViews[index].updateXLabel()
        parameterViews[index].updateYLabel()
        touchMeView.setPositionDirect(at: index, bind: value)
        bthDataSender.sendLastXYData()
    }
    
    func setXYZ(value: XYZPosition, at index: Int) {
        let xy = value.getXY()
        filterManager.willBeChange(in: index)
        filterManager.setBind(xyz: value, at: index)
        parameterViews[index].updateWhole()
        touchMeView.setPositionDirect(at: index, bind: xy)
        bthDataSender.sendLastZData()
        bthDataSender.sendLastXYData()
    }
    
    func setBand(value: OneBand, at index: Int) {
        let type = value.type
        storages[index].type = type
        filterManager.setBand(band: value, at: index)
        changePview(at: index, type: type)
        parameterViews[index].updateWhole()
        setFilterMenuSelection(index, type)
        touchMeView.resetDotLock(at: index)
        touchMeView.setPositionDirect(at: index, bind: value.getXY())
        touchMeView.setSectionActive(sectionController.selectedSegmentIndex)
        bthDataSender.sendBandData(at: index, band: value)
        setOnOff(value: value.isOn, at: index)
    }
    
    // 프리셋을 로딩했을 경우도 undo, redo 가 가능합니다.
    func setPreset(preset: [OneBand], at section: Int?) {
        var offset: Int = 0
        if let section = section, preset.count == 4 {
            offset = section * 4
        }
        for (i, band) in preset.enumerated() {
            setOnOff(value: true, at: i)
            setBand(value: band, at: i+offset)
        }
    }
}

extension MainViewController: FileExplorerVCDelegate {
    // preset Load, Save시에 사용하는 파일 익스플로러 입니다.
    // 한개의 VC로 구현이 가능했고, GPT가 솔직히 다했다.
    // 덕분에 어렵진 않았어요 금방했어요.
    private func presentFileExplorer(mode: FileExpMode, savePreset: [OneBand]) {
        let presetVC: FileExplorerViewController
        if mode == .save {
            presetVC = FileExplorerViewController(mode: .save, savePreset: savePreset, delegate: self)
        } else {
            presetVC = FileExplorerViewController(mode: .load, delegate: self)
        }
        let navController = UINavigationController(rootViewController: presetVC)
        navController.modalPresentationStyle = .pageSheet  // 또는 .pageSheet, .overFullScreen 등
        present(navController, animated: true, completion: nil)
    }
    
    func presetLoaded(_ preset: [OneBand], for section: Int?) {
        taskManager.presetWillset(at: section)
        if let section = section {
            sectionController.selectedSegmentIndex = section
            sectionChange(section)
        }
        setPreset(preset: preset, at: section)
        taskManager.presetDidset()
    }
}


extension MainViewController: BluetoothVCDelegate {
    // 하드웨어와 블루투스 통신에 대한 내용입니다.
    // 하드웨어에서 리퀘스트가 왔을 때,
    // 동기화요청 이나 바이패스 알림이 있습니다.
    func requestFromHW(command: String) {
        switch command {
        case "HW Sync Request":
            indicateHWRequest(command)
            bthDataSender.resetAllData(preset: storages)
        case "BypassOn":
            showHWBypassLabel(true)
        case "BypassOff":
            showHWBypassLabel(false)
            bthDataSender.resetAllData(preset: storages)
        default :
            indicateHWRequest("Unknown Request")
        }

    }
    private func showHWBypassLabel(_ isOn: Bool) {
        bypassLabel.isHidden = !isOn
    }
    private func indicateHWRequest(_ str: String){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.requestHWLabel.alpha = 0
            self.requestHWLabel.text = str
            self.requestHWLabel.isHidden = false
            UIView.animate(withDuration: 0.3, animations: { self.requestHWLabel.alpha = 1 }) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    UIView.animate(withDuration: 0.3, animations: { self.requestHWLabel.alpha = 0 }) { _ in
                        self.requestHWLabel.isHidden = true
                    }
                }
            }
        }
    }
    // 블루투스가 끊어졌을 때 알림을 띄웁니다.
    func bluetoothDisconnected(alert: UIAlertController) {
        self.present(alert, animated: true) { [weak self] in
            self?.setBthCircleActive(false)
        }
        self.bthDataSender.serial = nil
        showHWBypassLabel(false)
    }
    
    // 블루투스가 새로 연결되엇을 때 알림을 띄웁니다.
    func bluetoothConnected(serial: BluetoothSerial) {
        print("bthConnected from MVC")
        self.bthDataSender.serial = serial
        self.setBthCircleActive(true)
        bthDataSender.resetAllData(preset: storages)
    }
    func btWriteFailed() {  }
}
