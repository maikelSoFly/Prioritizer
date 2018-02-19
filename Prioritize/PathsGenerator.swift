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
    }

}
