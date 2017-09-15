//
//  PrioritizeTests.swift
//  PrioritizeTests
//
//  Created by Mikołaj Stępniewski on 04.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import XCTest
@testable import Prioritize

class PrioritizeTests: XCTestCase {
    

    
    func testExample() {
        let aims:[Task] = [
            Task(type: .aim, title: "Task1", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: true),
            Task(type: .aim, title: "Task2", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: true),
            Task(type: .aim, title: "Task3", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: true),
            Task(type: .aim, title: "Task4", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: false)
        ]
        let objectives:[Task] = [
            Task(type: .objective, title: "Task5", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: false),
            Task(type: .objective, title: "Task6", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: false),
            Task(type: .objective, title: "Task7", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: false),
            Task(type: .objective, title: "Task8", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: false),
            Task(type: .objective, title: "Task9", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: false),
            Task(type: .objective, title: "Task10", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: false),
            Task(type: .objective, title: "Task11", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: true),
            Task(type: .objective, title: "Task11", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: true)
        ]
        let targets:[Task] = [
            Task(type: .target, title: "Task12", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: true),
            Task(type: .target, title: "Task13", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: false),
            Task(type: .target, title: "Task14", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: true),
            Task(type: .target, title: "Task15", description: "test1", estimatedTime: TimeMeasurment(value: 7, unit:.year), isDone: false)
        ]
        let splitter = TaskSplitter(title: "SplitterTest", priorityCircleColors: [.red, .black, .white], estimatedTime: TimeMeasurment(value:99, unit: .year), aims: aims, objectives: objectives, targets: targets)
        
        let aimsPercentage = splitter.getProgress(for: .aims, of: .percentage)
        let objectivesPercentage = splitter.getProgress(for: .objectives, of: .percentage)
        let targetsPercentage = splitter.getProgress(for: .targets, of: .percentage)
        
        let aimsNumberDone = splitter.getProgress(for: .aims, of: .numberDone)
        
        XCTAssertEqual(aimsPercentage, 75)
        XCTAssertEqual(objectivesPercentage, 25)
        XCTAssertEqual(targetsPercentage, 50)
        XCTAssertEqual(aimsNumberDone, 3)
    }
    
   
    
}
