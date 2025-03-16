//
//  Statics.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/10/24.
//

import Foundation
    
// 그 작업관리자에서 다양한 타입의 파라미터 변경을 담기 위해서
// 아무 조건도 없는 Recordable 프로토콜을 선언했습니다.
protocol Recordable {}
// 한개의 작업을 기록하는 클래스 OneTask
class OneTask {
    let before: Recordable
    let after: Recordable
    let index: Int?

    init(at index: Int?, before: Recordable, after: Recordable) {
        let typeBEF = type(of: before); let typeAFT = type(of: after)
        guard typeBEF == typeAFT else { fatalError(" task type difference BEF: \(typeBEF), AFT: \(typeAFT)") }
        self.before = before
        self.after = after
        self.index = index
    }
}

// MainViewController가 TaskList와 협력하기 위해 갖추어야 할 명세.
protocol TaskListDelegate: MainViewController {
    func willChangeByTask(at index: Int)
    func setOnOff(value: Bool, at index: Int)
    func setZ(value: Double, at index: Int)
    func setDot(value: XYPosition, at index: Int)
    func setXYZ(value: XYZPosition, at index: Int)
    func setBand(value: OneBand, at index: Int)
    func setPreset(preset: [OneBand], at section: Int?)
    func setRedoEnable(_ isEnable: Bool)
    func setUndoEnable(_ isEnable: Bool)
}
extension Bool: Recordable {}


class TaskList {
    
    // MainViewController 입니다.
    weak var delegate: TaskListDelegate?
    
    //최대 작업기록 갯수.
    var listMaxCount = 127
    
    // 작업 기록 목록
    var taskList: [OneTask]
    
    // 작업 목록에서 현재 인덱스
    var listCurrentIndex: Int
    var activeIndex: Int? = nil
    
    //MainViewController에서 사용하는 파라미터 배열을 그대로 레퍼런스로 복사해옵니다.
    var storage: [OneBand] = []
    var bind: [XYZPosition] = []
    
    var pendingRecord: Recordable = factoryPreset_()
    
    var isTouchingDot: Bool = false
    var isTouchingSlider: Bool = true
    var pendingPosition = XYPosition(x: 0, y: 0)
    
    //MainViewController에서 생성자 호출해줍니다.
    // 파라미터 배열을 그대로 레퍼런스로 복사합니다.
    init(storage: [OneBand] = [], bind:[XYZPosition] = []) {
        self.storage = storage
        self.bind = bind
        self.taskList = []
        self.listCurrentIndex = -1
    }
    
    // 각종 파라미터 변경에 대응하는 함수.,
    // 종류에 따라서 변경시작 / 변경 완료 로 나누어진 경우와 그렇지 않은 경우가 있습니다.
    func OnOffChanged(at index: Int, to value: Bool) {
        activeIndex = index
        listAppend(before: !value, after: value)
    }
    
    func sliderWillMove(at index: Int) {
        isTouchingSlider = true
        activeIndex = index
        pendingRecord = bind[index].getZ()
    }
    
    func sliderDidMove() {
        guard isTouchingSlider, let index = activeIndex else { return }
        isTouchingSlider = false
        let recordZ = bind[index].getZ()
        listAppend(before: pendingRecord, after: recordZ)
    }
    
    func dotWillMove(at index: Int) {
        isTouchingDot = true
        activeIndex = index
        let position = bind[index].getXY()
        pendingRecord = position
        pendingPosition = position
    }
    func dotDidMove() {
        guard isTouchingDot, let index = activeIndex else { return }
        let recordXY = bind[index].getXY()
        guard pendingPosition != recordXY else { return }
        listAppend(before: pendingRecord, after: recordXY)
        isTouchingDot = false
    }
    
    func xyzWillChange(at index: Int) {
        activeIndex = index
        pendingRecord = bind[index].copy()
    }
    func xyzDidChange() {
        guard let index = activeIndex else { return }
        let recordXYZ = bind[index].copy()
        listAppend(before: pendingRecord, after: recordXYZ)
    }
    
    func bandWillChange(at index: Int) {
        activeIndex = index
        pendingRecord = storage[index].copy()
    }
    func bandDidChange() {
        guard let index = activeIndex else { return }
        let recordBand = storage[index].copy()
        listAppend(before: pendingRecord, after: recordBand)
    }
    
    func presetWillset(at section: Int?) {
        if let section = section {
            activeIndex = section*4
        }
        pendingRecord = Preset(bands: storage).copy()
    }
    func presetDidset() {
        let recordPreset = Preset(bands: storage).copy()
        listAppend(before: pendingRecord, after: recordPreset)
    }
    
    // 하나의 파라미터 변경 작업이 완료되면
    // 해당 작업을 리스트에 기록하는 함수입니다.
    func listAppend(before: Recordable, after: Recordable) {
        let task = OneTask(at: activeIndex, before: before, after: after)
        
        let lastIndex = taskList.count - 1
        // 일정횟수 Undo했다가 다시 새로운 작업이 들어온 경우,
        // 현재시점 이후로 기록된 작업은 삭제합니다.
        if listCurrentIndex < lastIndex { // 현재 인덱스보다 후순위는 삭제.
            taskList = Array(taskList.prefix(listCurrentIndex + 1))
            delegate?.setRedoEnable(false)
        }
        
        // 127개의 목록이 꽉찼다면.
        else if listCurrentIndex == listMaxCount {
            taskList.removeFirst()
            listCurrentIndex -= 1
        }
        
        taskList.append(task)
        listCurrentIndex += 1
        
        // 리스트 갯수가 0개여서 Undo 작업이 가능해진 시점이라면 Undo버튼을 활성화해야합니다.
        if listCurrentIndex == 0 { delegate?.setUndoEnable(true) }
    }
        
    func undo() {
        guard listCurrentIndex >= 0 else { return }
        if listCurrentIndex == taskList.count - 1 { delegate?.setRedoEnable(true) }
        if listCurrentIndex == 0 { delegate?.setUndoEnable(false) }
        let task = taskList[listCurrentIndex]
        listCurrentIndex -= 1
        function(for: task.before, at: task.index)
    }
    
    func redo() {
        guard listCurrentIndex < taskList.count - 1 else { return }
        if listCurrentIndex == taskList.count - 2 { delegate?.setRedoEnable(false) }
        if listCurrentIndex == -1 { delegate?.setUndoEnable(true) }
        listCurrentIndex += 1
        let task = taskList[listCurrentIndex]
        function(for: task.after, at: task.index)
    }
    
    // Undo, Redo에서 호출하는 함수입니다.
    // 작업의 종류에 따라서 동작이 다릅니다.
    private func function(for record: Recordable, at index: Int?) {
        if let index = index { delegate?.willChangeByTask(at: index) }
        switch record {
        case let onOffRecord as Bool:
            delegate?.setOnOff(value: onOffRecord, at: index!)
        case let zRecord as Zonly:
            delegate?.setZ(value: zRecord.z_(), at: index!)
        case let dotRecord as XYPosition:
            delegate?.setDot(value: dotRecord, at: index!)
        case let xyzRecord as XYZPosition:
            delegate?.setXYZ(value: xyzRecord, at: index!)
        case let bandRecord as OneBand:
            delegate?.setBand(value: bandRecord, at: index!)
        case let presetRecord as Preset:
            delegate?.setPreset(preset: presetRecord.bands, at: index)
        default:
            return
        }
    }
}

