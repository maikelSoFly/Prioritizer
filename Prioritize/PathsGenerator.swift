//
//  PathsGenerator.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 27.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class PathsGenerator: NSObject {
    var endPoints:[CGPoint]
    var startPoint:CGPoint
    var pathsDictionary = [NSValue : UIBezierPath]()
    
    init(startPoint:CGPoint, endPoints:[CGPoint]) {
        self.startPoint = startPoint
        self.endPoints = endPoints
        super.init()
        self.createPathsDictionary()
    }
    
    private func createPathsDictionary() {
        for point in endPoints {
            let path = UIBezierPath()
            path.move(to: startPoint)
            
            enum BendingDirection {
                case left, none, right
            }
            
            var bendingDirection:BendingDirection?
            
            let subtraction = startPoint.x - point.x
            if subtraction == 0 {
                bendingDirection = .none
            } else if subtraction < 0 {
                bendingDirection = .right
            } else {
                bendingDirection = .left
            }
            
            //MARK: - Mid point.
            var midpoint = CGPoint(x: (startPoint.x + point.x)/2, y: (startPoint.y + point.y)/2)
            
            switch bendingDirection {
            case .right?:
                midpoint.x += 20
                break
            case .left?:
                midpoint.x -= 20
                break
            default: break
            }
            
            path.addQuadCurve(to: point, controlPoint: midpoint)
            
            pathsDictionary[ NSValue(cgPoint: point) ] = path
        }
        
        
//        path.move(to: startPoint)
//
//        enum Direction {
//            case left, down, right
//        }
//        var direction:Direction = .right
//
//        if startPoint.x < endPoint.x {
//            direction = .right
//        }
//
//        else if startPoint.x > endPoint.x {
//            direction = .left
//        }
//
//        else {
//            direction = .down
//        }
//
//        /// Mid-point
//        var midPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
//
//        if direction == .right {
//            midPoint.x += 20
//        } else if direction == .left {
//            midPoint.x -= 20
//        }
//
//        path.addQuadCurve(to: endPoint, controlPoint: midPoint)
//
//        paths.append(path)
    }

}
