//
//  Task.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 18.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class Task: NSObject {
    public var title:String
    public var additionalDescription:String
    public var priority:TaskPriority // Granted by user.
    public var maxRealizationTime:Measurement<UnitDuration> // Provided by user
    public var maxRealizationTimeInSeconds:Measurement<UnitDuration> {
        get {
            return maxRealizationTime.converted(to: .seconds)
        }
    }
    private var taskDurationTime:Double { /// From when task is added till deadline
        get {
            return deadline.timeIntervalSince(timestamp)
        }
    }
    private var freeTime:Double { /// ADDED--FREETIME--MAXREALIZATIONTIME--DEADLINE
        get {
            return taskDurationTime - maxRealizationTimeInSeconds.value
        }
    }
    public var currentDuration:Double {
        return abs(timestamp.timeIntervalSinceNow)
    }
    public var deadline:Date
    public var timestamp:Date
    
    /// Returns specific PriorityTier to assign task to proper group.
    /// Default partitions:
    ///     • Tier 3: from 0 - 50% of freeTime                              (OPTIONAL)
    ///     • Tier 2: from 50% of freeTime till 20% of maxRealizationTime   (MODERATE)
    ///     • Tier 1: from 20% of maxRealizationTime                        (URGENT)
    var _tier:PriorityTier = .optional {
        didSet {
            
        }
    }
    var tier:PriorityTier {
        get {
            let tier2Border = (freeTime * 0.5) + priorityOffset
            let tier1Border = (freeTime + maxRealizationTimeInSeconds.value * 0.2) + priorityOffset
            
            
            if currentDuration >= taskDurationTime {
                _tier = .outdated
                return .outdated
            }
            
            if currentDuration >= tier1Border {
                _tier = .urgent
                return .urgent
            } else if currentDuration >= tier2Border {
                _tier = .moderate
                return .moderate
            } else {
                _tier = .optional
                return .optional
            }
        }
    }
    
    /// Remaining time till deadline.
    /// Calculated from deadline and current time.
    var remainingTime:Measurement<UnitDuration> {
        get { // Returns remaing time till deadline in minutes.
            let timeInterval = deadline.timeIntervalSinceNow // in seconds
            let minutes = Measurement<UnitDuration>(value: timeInterval, unit: .seconds).converted(to: .minutes)
            return Measurement<UnitDuration>(value: round(minutes.value), unit: .minutes)
        }
    }
    
    /// Offsetting PriorityCircle's tiers borders.
    /// PriorityOffset moves Tier 1 border from 0 - 40% of maxRealizationTime.
    /// Tier 2 border moves synchronously with Tier 1 border (!)
    ///
    /// Priority offsets:
    ///     • Low priority: 40% of maxRealizationTime
    ///     • Normal priority (default): 20% of maxRealizationTime
    ///     • High priority: 0% of maxRealizationTime
    private var priorityOffset:Double {
        get {
            switch priority {
            case .low:
                return 0.2 * maxRealizationTimeInSeconds.value
            case .normal:
                return 0
            case .high:
                return -(0.2 * maxRealizationTimeInSeconds.value)
            }
        }
    }
    var isDone:Bool = false
    
    
    
    init(title:String, description:String, priority:TaskPriority, deadline:Date, maxRealizationTime:Measurement<UnitDuration>) {
        self.title = title
        self.additionalDescription = description
        self.priority = priority
        self.deadline = deadline
        self.maxRealizationTime = maxRealizationTime
        self.timestamp = Date(timeIntervalSinceNow: 0)
    }
}

enum TaskPriority {
    case low, normal, high
}

enum PriorityTier {
    case optional, moderate, urgent, outdated
}
