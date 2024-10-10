//
//  Statics.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/10/24.
//

import Foundation
    
protocol Recordable {}
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

protocol TaskListDelegate: MainViewController {
    func willChangeByTask(at index: Int)
    func setZ(value: Double, at index: Int)
    func setDot(value: XYPosition, at index: Int)
    func setXYZ(value: XYZPosition, at index: Int)
    func setBand(value: OneBand, at index: Int)
    func setPreset(preset: Preset)
    func setRedoEnable(_ isEnable: Bool)
    func setUndoEnable(_ isEnable: Bool)
}

class TaskList {
    
    weak var delegate: TaskListDelegate?
    
    var listMaxCount = 127
    var taskList: [OneTask]
    var listCurrentIndex: Int
    var activeIndex: Int? = nil
    var storage: [OneBand] = []
    var bind: [XYZPosition] = []
    var pendingRecord: Recordable = factoryPreset_()
    var isTouchingDot: Bool = false
    var isTouchingSlider: Bool = true
    var pendingPosition = XYPosition(x: 0, y: 0)
    
    
    init(storage: [OneBand] = [], bind:[XYZPosition] = []) {
        self.storage = storage
        self.bind = bind
        self.taskList = []
        self.listCurrentIndex = -1
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
    
    func presetWillset() {
        activeIndex = nil
        pendingRecord = Preset(bands: storage)
    }
    func presetDidset() {
        let recordPreset = Preset(bands: storage)
        listAppend(before: pendingRecord, after: recordPreset)
    }
    
    
    func listAppend(before: Recordable, after: Recordable) {
        let task = OneTask(at: activeIndex, before: before, after: after)
        
        let lastIndex = taskList.count - 1
        if listCurrentIndex < lastIndex { // 현재 인덱스보다 후순위는 삭제.
            taskList = Array(taskList.prefix(listCurrentIndex + 1))
            delegate?.setRedoEnable(false)
        }
        else if listCurrentIndex == listMaxCount {
            taskList.removeFirst()
            listCurrentIndex -= 1
        }
        taskList.append(task)
        listCurrentIndex += 1
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
    
    private func function(for record: Recordable, at index: Int?) {
        if let index = index { delegate?.willChangeByTask(at: index) }
        switch record {
        case let zRecord as Zonly:
            delegate?.setZ(value: zRecord.z_(), at: index!)
        case let dotRecord as XYPosition:
            delegate?.setDot(value: dotRecord, at: index!)
        case let xyzRecord as XYZPosition:
            delegate?.setXYZ(value: xyzRecord, at: index!)
        case let bandRecord as OneBand:
            delegate?.setBand(value: bandRecord, at: index!)
        case let presetRecord as Preset:
            delegate?.setPreset(preset: presetRecord)
        default:
            return
        }
    }
}

