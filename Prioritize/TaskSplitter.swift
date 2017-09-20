//
//  TaskSplitter.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 04.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class TimeMeasurment {
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
    var urgents:[Task]
    var moderates:[Task]
    var optionals:[Task]
    var outdated:[Task]
    
    enum ProgressType {
        case percentage
        case numberDone
    }
    
    
    //Initializing empty goal
    init(title:String, estimatedTime:TimeMeasurment, priorityCircleColors:[UIColor]) {
        self.title = title
        self.estimatedTime = estimatedTime
        self.priorityCircleColors = priorityCircleColors
        self.urgents = [Task]()
        self.moderates = [Task]()
        self.optionals = [Task]()
        self.outdated = [Task]()
    
    }
    
    //Initializing goal with existing aims, objectives and targets
    init(title:String, priorityCircleColors:[UIColor], estimatedTime:TimeMeasurment, urgents:[Task], moderates:[Task], optionals:[Task]) {
        self.title = title
        self.estimatedTime = estimatedTime
        self.priorityCircleColors = priorityCircleColors
        self.urgents = urgents
        self.moderates = moderates
        self.optionals = optionals
        self.outdated = [Task]()
    }
    
    //Copying existing goal
    init(splitter:TaskSplitter) {
        self.title = splitter.title
        self.estimatedTime = splitter.estimatedTime
        self.priorityCircleColors = splitter.priorityCircleColors
        self.urgents = splitter.urgents
        self.moderates = splitter.moderates
        self.optionals = splitter.optionals
        self.outdated = splitter.outdated
    }
    
    
    
    // 🔥 FUNCTIONS 🔥
    
    
    
    func clearAllTasks() {
        self.urgents.removeAll()
        self.moderates.removeAll()
        self.optionals.removeAll()
        self.outdated.removeAll()
    }
    
    func clearTaks(in tier:PriorityTier) {
        switch tier {
        case .optional:
            optionals.removeAll()
            break
        case .moderate:
            moderates.removeAll()
            break
        case .urgent:
            urgents.removeAll()
            break
        case .outdated:
            outdated.removeAll()
        }
    }
    
    func getProgress(for structure: TaskSplitterStructure, of type:ProgressType) -> Double {
        var numberDone:Double = 0
        var count:Double = 0
        
        switch structure {
        case .urgents:
            for aim in self.urgents {
                numberDone += aim.isDone ? 1 : 0
            }
            count = Double(self.urgents.count)
            break
        case .moderates:
            for objective in self.moderates {
                numberDone += objective.isDone ? 1 : 0
            }
            count = Double(self.moderates.count)
            break
        case .optionals:
            for target in self.optionals {
                numberDone += target.isDone ? 1 : 0
            }
            count = Double(self.optionals.count)
            break
        case .all:
            for objective in self.moderates {
                numberDone += objective.isDone ? 1 : 0
            }
            for target in self.optionals {
                numberDone += target.isDone ? 1 : 0
            }
            for aim in self.urgents {
                numberDone += aim.isDone ? 1 : 0
            }
            count = Double(self.urgents.count + self.moderates.count + self.optionals.count)
        }
        
        return type == .percentage ? (numberDone / count) * 100 : numberDone
    }
    
    //Add new task to do
    func addTask(title:String, with description:String, priority:TaskPriority, deadline:Date, maxRealizationTime:Measurement<UnitDuration>) {
        let task = Task(title: title, description: description, priority: priority, deadline: deadline, maxRealizationTime: maxRealizationTime)
        
        switch task.tier {
        case .optional:
            optionals.append(task)
            break
        case .moderate:
            moderates.append(task)
            break
        case .urgent:
            urgents.append(task)
            break
        default:
            print("❗Task is outdated.")
        }
    }
    
    func addTasks(_ tasks:[Task]) {
        for task in tasks {
            switch task.tier {
            case .optional:
                optionals.append(task)
                break
            case .moderate:
                moderates.append(task)
                break
            case .urgent:
                urgents.append(task)
                break
            default:
                print("❗Task is outdated.")
            }
        }
    }
    
    
    func sortByRemainingTime(structure:TaskSplitterStructure) {
        switch structure {
        case .urgents:
            self.urgents.sort(by: {$0.remainingTime < $1.remainingTime})
            break
        case .moderates:
            self.moderates.sort(by: {$0.remainingTime < $1.remainingTime})
            break
        case .optionals:
            self.optionals.sort(by: {$0.remainingTime < $1.remainingTime})
            break
        case .all:
            self.urgents.sort(by: {$0.remainingTime < $1.remainingTime})
            self.moderates.sort(by: {$0.remainingTime < $1.remainingTime})
            self.optionals.sort(by: {$0.remainingTime < $1.remainingTime})
            break
        }
    }
    
    func reloadData(for tier:PriorityTier) {
        switch tier {
        case .optional:
            for (index, task) in optionals.enumerated() {
                if task._tier != task.tier {
                    moveTask(task, to: task.tier)
                    optionals.remove(at: index)
                }
            }
            break
        case .moderate:
            for (index, task) in optionals.enumerated() {
                if task._tier != task.tier {
                    moveTask(task, to: task.tier)
                    moderates.remove(at: index)
                }
            }
            break
        case .urgent:
            for (index, task) in optionals.enumerated() {
                if task._tier != task.tier {
                    moveTask(task, to: task.tier)
                    urgents.remove(at: index)
                }
            }
            break
        case .outdated:
            print("❗No need to reload outdated tasks.")
            break
        }
    }
    
    private func moveTask(_ task:Task, to tier:PriorityTier) {
        switch tier {
        case .optional:
            optionals.append(task)
            break
        case .moderate:
            moderates.append(task)
            break
        case .urgent:
            urgents.append(task)
            break
        case .outdated:
            outdated.append(task)
        }
    }
    
    
}
