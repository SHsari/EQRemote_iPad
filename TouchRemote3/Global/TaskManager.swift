//
//  Statics.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/10/24.
//

import Foundation

class Task_Band {
    let before: OneBand
    let after: OneBand
    let index: Int
    
    init(at index: Int, before: OneBand, after: OneBand) {
        self.before = before.copy() as! OneBand
        self.after = after.copy() as! OneBand
        self.index = index
    }
}

class Task_Preset {
    let before: Preset
    let after: Preset
    init(before: Preset, after: Preset) {
        self.before = before.copy() as! Preset
        self.after = after.copy() as! Preset
    }
}

enum Task {
    case Band(Task_Band)
    case Preset(Task_Preset)
}

class TaskList {

    var listMaxIndex = 127
    var taskList: [Task]
    var listCurrentIndex: Int
    
    init() {
        self.taskList = []
        self.listCurrentIndex = -1
    }
    
    func listAppend(_ index: Int?) {
        let lastIndex = taskList.count - 1
        if listCurrentIndex < lastIndex { // list의 중간에서 Append 하게 될 때, 후순위로 저장되어 있던 동작을 모두 지움.
            if lastIndex == -1 { taskList = [] }
            else { taskList = Array(taskList[0...listCurrentIndex])
                print("taskList.count: \(taskList.count)") }
        } else if listCurrentIndex == listMaxIndex {
            taskList.removeFirst()
            listCurrentIndex -= 1
        }
        if let index = index {
            let task = Task.Band(Task_Band(at: index, before: pendingTaskBand, after: globalBands[index]))
            taskList.append(task)
        } else {
            let task = Task.Preset(Task_Preset(before: pendingTaskPreset, after: Preset(bands: globalBands)))
            taskList.append(task)
        }
        listCurrentIndex += 1
        print("listCurrentIndex: \(listCurrentIndex)")
    }
    
    func undo() -> Int? {
        guard listCurrentIndex >= 0 else { return nil }
        let task = taskList[listCurrentIndex]
        listCurrentIndex -= 1
        print("listCurrentIndex: \(listCurrentIndex)")
        switch task {
        case .Band(let taskBand):
            let bandIndex = taskBand.index
            globalBands[bandIndex] = taskBand.before
            return bandIndex
        case .Preset(let taskPreset):
            globalBands = taskPreset.before.bands
            return -1
        }
        
    }
    
    func redo() -> Int?{
        guard listCurrentIndex < taskList.count - 1 else { return nil }
        listCurrentIndex += 1
        print("listCurrentIndex: \(listCurrentIndex)")
        let task = taskList[listCurrentIndex]
        switch task {
        case .Band(let taskBand):
            let bandIndex = taskBand.index
            globalBands[bandIndex] = taskBand.after
            return bandIndex
        case .Preset(let taskPreset):
            globalBands = taskPreset.after.bands
            return -1
        }
        
    }
}
