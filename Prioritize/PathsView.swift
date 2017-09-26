//
//  PathsView.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 25.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class PathsView: UIView {
    var paths = [UIBezierPath]()
    
    override func draw(_ rect: CGRect) {
        for path in paths {
            path.lineWidth = 2
            path.lineCapStyle = .round
            UIColor.magenta.setStroke()
            path.stroke()
        }
    }

    
    func addCustomPath(moveTo startPoint:CGPoint, endAt endPoint:CGPoint) {
        let path = UIBezierPath()
        path.move(to: startPoint)
        
        enum Direction {
            case left, down, right
        }
        var direction:Direction = .right
        
        if startPoint.x < endPoint.x {
            direction = .right
        }
        
        else if startPoint.x > endPoint.x {
            direction = .left
        }
        
        else {
            direction = .down
        }
        
        /// Mid-point
        var midPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
        
        if direction == .right {
            midPoint.x += 20
        } else if direction == .left {
            midPoint.x -= 20
        }
        
        path.addQuadCurve(to: endPoint, controlPoint: midPoint)
        
        paths.append(path)
    }

}
