//
//  RocketPathControl.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 27.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

protocol RocketDelegate {
    func rocketLanded(rocket:Rocket, on position:CGPoint)
}

class Rocket: UIImageView {
    weak var task:Task?
    var endPoint:CGPoint!
    var delegate:RocketDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func fly(from startPoint:CGPoint, withPath path:UIBezierPath, rotateTowardsBlackHole blackHoleCenter:CGPoint) {
        self.endPoint = path.currentPoint
        let angleToTarget = endPoint.angle(to: blackHoleCenter)
        let halfwayAngle = startPoint.angle(to: endPoint)
       
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(rotationAngle: halfwayAngle - (CGFloat.pi/2))
        }) { (success) in
            UIView.animate(withDuration: 1.5, animations: {
                self.transform = CGAffineTransform(rotationAngle: angleToTarget - (CGFloat.pi/2))
            }, completion: nil)
        }
       
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.delegate = self
        animation.path = path.cgPath
        animation.fillMode = kCAFillModeForwards
        //animation.isRemovedOnCompletion = false
        animation.duration = 2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.layer.add(animation, forKey: nil)
    }
}

extension Rocket:CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            delegate?.rocketLanded(rocket: self, on: endPoint!)
        }
    }
}
