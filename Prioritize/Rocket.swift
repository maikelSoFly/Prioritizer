//
//  RocketPathControl.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 27.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

@objc protocol RocketDelegate {
    func aproachedBlackHole(rocket:Rocket, on position:CGPoint)
    func isAproachingBlackHole()
    func rocketCanBeRemoved(rocket:Rocket)
    func moved()
}

class Rocket: UIImageView {
    weak var task:Task?
    var lastEndPoint:CGPoint!
    weak var delegate:RocketDelegate!
    private(set) var isInBlackHole = false
    var startingPosition:CGPoint!
    private(set) var uuid:String
    private var previousTier:Tier
    private var tierIndicator:CALayer!
    
    init(frame: CGRect, uuid:String, task:Task) {
        self.uuid = uuid
        self.task = task
        self.previousTier = .optional
        super.init(frame: frame)
        decorate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Rocket \(uuid) deinitialized.")
    }
    
    func decorate() {
        tierIndicator = CALayer()
        let width = CGFloat(5.0)
        tierIndicator.backgroundColor = UIColor.white.cgColor
        let frameW = frame.width, frameH = frame.height
        tierIndicator.frame = CGRect(x: frameW/2-width/2, y: frameH + 4.0, width: width, height: width)
        
        tierIndicator.cornerRadius = width/2
        tierIndicator.borderColor = UIColor.black.cgColor
        tierIndicator.borderWidth = 0.5
        layer.addSublayer(tierIndicator)
        layer.masksToBounds = false
    }
    
    
    public func fly(from startPoint:CGPoint, withPath path:UIBezierPath, rotateTowardsBlackHole blackHoleCenter:CGPoint) {
        self.lastEndPoint = path.currentPoint
        let angleToTarget = lastEndPoint.angle(to: blackHoleCenter)
        let halfwayAngle = startPoint.angle(to: lastEndPoint)
       
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
        animation.duration = 2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.layer.add(animation, forKey: nil)
    }
    
    
    func flyAway(by distance:CGFloat, towards destinationPoint:CGPoint) {
        let path = UIBezierPath()
        let x3, y3:CGFloat
        let x1 = center.x, y1 = center.y, x2 = destinationPoint.x, y2 = destinationPoint.y
        let D = hypot(x1 - x2, y1 - y2)
        
        if self.task?.recentTier != previousTier {
            print("Task \(String(describing: task?.title)) changed from \(previousTier.rawValue) to \(task?.tier.rawValue ?? "")")
            
            if task?.recentTier == .moderate {
                tierIndicator.backgroundColor = UIColor.red.cgColor
                tierIndicator.borderColor = UIColor.lightGray.cgColor
            } else {
                tierIndicator.backgroundColor = UIColor.black.cgColor
            }
            
            
            previousTier = (task?.recentTier)!
        }
        
        let distanceDone = hypot(startingPosition.x-center.x, startingPosition.y-center.y)
        print("Distance done", distanceDone)
        let distance = distance - distanceDone
        
        x3 = x1 + (distance/D)*(x2-x1)
        y3 = y1 + (distance/D)*(y2-y1)
        
        lastEndPoint = CGPoint(x: x3, y: y3)
        
        path.move(to: center)
        path.addLine(to: lastEndPoint)
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.delegate = self
        animation.path = path.cgPath
        animation.fillMode = kCAFillModeForwards
        //animation.isRemovedOnCompletion = false
        animation.duration = 0.75
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.layer.add(animation, forKey: nil)
        self.center = lastEndPoint
        
        print("Moving rocket with task \(task?.title ?? "none") by \(distance) px")
    }
}

//MARK: - EXTENSIONS

extension Rocket:CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag && !isInBlackHole {
            isInBlackHole = true
            delegate?.aproachedBlackHole(rocket: self, on: lastEndPoint!)
        } else {
            layer.removeAllAnimations()
            if task?.recentTier == .outdated {
                self.removeFromSuperview()
                delegate.rocketCanBeRemoved(rocket: self)
            }
            delegate.moved()
        }
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        if !isInBlackHole {
            delegate?.isAproachingBlackHole()
        }
    }
}
