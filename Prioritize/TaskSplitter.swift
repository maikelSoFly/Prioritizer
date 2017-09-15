//
//  TaskSplitter.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 04.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

struct Task {
    var type:TaskType
    var title:String
    var description:String
    var estimatedTime:TimeMeasurment
    var isDone:Bool
}

struct TimeMeasurment {
    var value:Int
    var unit:CFCalendarUnit
    var minutes:Double {
        get {
            switch unit {
            case CFCalendarUnit.minute:
                return Double(value)
            case CFCalendarUnit.hour:
                return Double(value * 60)
            case CFCalendarUnit.day:
                return Double(value * 60 * 24)
            case CFCalendarUnit.month:
                return Double(value) * 43829.0639
            case CFCalendarUnit.year:
                return Double(value) * 60 * 24 * 365.242199
            default:
                return 1
            }
        }
    }
    init(value:Int, unit:CFCalendarUnit) {
        self.value = value
        self.unit = unit
    }
}

class TaskSplitter: NSObject {
    var priorityCircleColors:[UIColor]
    var estimatedTime:TimeMeasurment
    var title:String
    var aims:[Task]
    var objectives:[Task]
    var targets:[Task]
    
    enum ProgressType {
        case percentage
        case numberDone
    }
    
    
    //Initializing empty goal
    init(title:String, estimatedTime:TimeMeasurment, priorityCircleColors:[UIColor]) {
        self.title = title
        self.estimatedTime = estimatedTime
        self.priorityCircleColors = priorityCircleColors
        self.aims = [Task]()
        self.objectives = [Task]()
        self.targets = [Task]()
    
    }
    
    //Initializing goal with existing aims, objectives and targets
    init(title:String, priorityCircleColors:[UIColor], estimatedTime:TimeMeasurment, aims:[Task], objectives:[Task], targets:[Task]) {
        self.title = title
        self.estimatedTime = estimatedTime
        self.priorityCircleColors = priorityCircleColors
        self.aims = aims
        self.objectives = objectives
        self.targets = targets
    }
    
    //Copying existing goal
    init(splitter:TaskSplitter) {
        self.title = splitter.title
        self.estimatedTime = splitter.estimatedTime
        self.priorityCircleColors = splitter.priorityCircleColors
        self.aims = splitter.aims
        self.objectives = splitter.objectives
        self.targets = splitter.targets
    }
    
    
    
    // 🔥 FUNCTIONS 🔥
    
    
    
    func clearAllTasks() {
        self.aims.removeAll()
        self.objectives.removeAll()
        self.targets.removeAll()
    }
    
    func getProgress(for structure: TaskSplitterStructure, of type:ProgressType) -> Double {
        var numberDone:Double = 0
        var count:Double = 0
        
        switch structure {
        case .aims:
            for aim in self.aims {
                numberDone += aim.isDone ? 1 : 0
            }
            count = Double(self.aims.count)
            break
        case .objectives:
            for objective in self.objectives {
                numberDone += objective.isDone ? 1 : 0
            }
            count = Double(self.objectives.count)
            break
        case .targets:
            for target in self.targets {
                numberDone += target.isDone ? 1 : 0
            }
            count = Double(self.targets.count)
            break
        case .all:
            for objective in self.objectives {
                numberDone += objective.isDone ? 1 : 0
            }
            for target in self.targets {
                numberDone += target.isDone ? 1 : 0
            }
            for aim in self.aims {
                numberDone += aim.isDone ? 1 : 0
            }
            count = Double(self.aims.count + self.objectives.count + self.targets.count)
        }
        
        return type == .percentage ? (numberDone / count) * 100 : numberDone
    }
    
    //Add new task to do
    func addTask(title:String, with description:String, of type:TaskType, of estimatedTime:TimeMeasurment) {
        let task = Task(type: type, title: title, description: description, estimatedTime: estimatedTime, isDone: false)
        
        switch type {
        case .aim:
            self.aims.append(task)
            break
        case .objective:
            self.objectives.append(task)
            break
        case .target:
            self.targets.append(task)
        default:
            print("❗Adding task of type: none")
        }
    }
    
    //Get const info about task type division basis
    func getTimeRange(for type:TaskType) -> (from:TimeMeasurment?, to:TimeMeasurment?) {
        switch type {
        case .aim:
            let from = TimeMeasurment(value: 5, unit: .year)
            return (from, nil)
        case .objective:
            let from = TimeMeasurment(value: 3, unit: .month)
            let to = TimeMeasurment(value: 24, unit: .month)
            return (from, to)
        case .target:
            let to = TimeMeasurment(value: 3, unit: .month)
            return (nil, to)
        default:
            print("❗Adding task of type: none")
            return (nil, nil)
        }
    }
    
    func sortByEstimatedTime(structure:TaskSplitterStructure) {
        switch structure {
        case .aims:
            self.aims.sort(by: {$0.estimatedTime.minutes < $1.estimatedTime.minutes})
            break
        case .objectives:
            self.objectives.sort(by: {$0.estimatedTime.minutes < $1.estimatedTime.minutes})
            break
        case .targets:
            self.targets.sort(by: {$0.estimatedTime.minutes < $1.estimatedTime.minutes})
            break
        case .all:
            self.aims.sort(by: {$0.estimatedTime.minutes < $1.estimatedTime.minutes})
            self.objectives.sort(by: {$0.estimatedTime.minutes < $1.estimatedTime.minutes})
            self.targets.sort(by: {$0.estimatedTime.minutes < $1.estimatedTime.minutes})
            break
        }
    }
    
    
}
