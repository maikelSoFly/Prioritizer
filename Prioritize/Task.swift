//
//  Task.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 18.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class Task {
    public var title:String
    public var additionalDescription:String
    public var color:UIColor
    private(set) var uuid:String
    private(set) var priority:TaskPriority
    private(set) var maxRealizationTime:Measurement<UnitDuration> // Provided by user
    public var maxRealizationTimeInSeconds:Measurement<UnitDuration> {
        get {
            return maxRealizationTime.converted(to: .seconds)
        }
    }
    public var taskDurationTime:Double { /// From when task is added till deadline
        get {
            return deadline.timeIntervalSince(timestamp)
        }
    }
    public var freeTime:Double { /// ADDED--FREETIME--MAXREALIZATIONTIME--DEADLINE
        get {
            
            return taskDurationTime - maxRealizationTimeInSeconds.value
        }
    }
    public var currentDuration:Double {
        get {
            return abs(timestamp.timeIntervalSinceNow)
        }
    }
    /// Elapsed part of task's lifespan.
    public var progress:TimeInterval {
        get {
            return currentDuration/self.lifespan
        }
    }
    private(set) var deadline:Date
    private(set) var timestamp:Date
    private let lifespan:TimeInterval
    
    /// Returns specific PriorityTier to assign task to proper group.
    /// Default partitions:
    ///     • Tier 3: from 0 - 50% of freeTime                              (OPTIONAL)
    ///     • Tier 2: from 50% of freeTime till 20% of maxRealizationTime   (MODERATE)
    ///     • Tier 1: from 20% of maxRealizationTime                        (URGENT)
    private(set) var recentTier:Tier = .optional
    public var tier:Tier {
        get {
            let tier2Border = (freeTime * 0.5) + priorityOffset
            let tier1Border = (freeTime + maxRealizationTimeInSeconds.value * 0.2) + priorityOffset
            
            if currentDuration >= taskDurationTime {
                recentTier = .outdated
                return .outdated
            }
            
            if currentDuration >= tier1Border {
                recentTier = .urgent
                return .urgent
            } else if currentDuration >= tier2Border {
                recentTier = .moderate
                return .moderate
            } else {
                recentTier = .optional
                return .optional
            }
        }
    }
    
    
    func calculateRocketDistance(from startPoint:CGPoint, endPoint:CGPoint) -> CGFloat? {
        var dist:CGFloat
        let D = hypot(startPoint.x - endPoint.x, startPoint.y - endPoint.y)
    
        let t2Border = (freeTime * 0.5) + priorityOffset
        let t1Border = (freeTime + maxRealizationTimeInSeconds.value * 0.2) + priorityOffset
        
        switch tier {
        case .optional:
            dist = CGFloat(currentDuration).remap(from1: 0, to1: CGFloat(t2Border), from2: 0, to2: D/3)
            break
        case .moderate:
            dist = CGFloat(currentDuration).remap(from1: CGFloat(t2Border), to1: CGFloat(t1Border), from2: D/3, to2: 2*(D/3))
            break
        case .urgent:
            dist = CGFloat(currentDuration).remap(from1: CGFloat(t1Border), to1: CGFloat(lifespan), from2: 2*(D/3), to2: D)
            break
        case .outdated:
            dist = D
        }
        
        return dist
    }
    

    /// Remaining time till deadline.
    /// Calculated from deadline and current time.
    public var remainingTime:TimeInterval {
        get { // Returns remaing time till deadline in minutes.
            return deadline.timeIntervalSinceNow // in seconds
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
    public var isDone:Bool = false
    
    
    
    init(title:String, description:String, priority:TaskPriority, deadline:Date, maxRealizationTime:Measurement<UnitDuration>, color:UIColor, uuid:String) {
        self.title = title
        self.additionalDescription = description
        self.priority = priority
        self.deadline = deadline
        self.maxRealizationTime = maxRealizationTime
        self.color = color
        self.timestamp = Date(timeIntervalSinceNow: 0)
        self.uuid = uuid
        self.lifespan = deadline.timeIntervalSinceNow
    }
    
    deinit {
        print("Task \(uuid) deinitialized.")
    }
}

enum TaskPriority {
    case low, normal, high
}

enum Tier:String {
    case optional = "OPTIONAL"
    case moderate = "MODERATE"
    case urgent = "URGENT"
    case outdated = "OUTDATED"
}
