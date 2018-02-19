//
//  CircularTransition.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 06.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class CircularTransition: NSObject {
    var duration:TimeInterval = 0.1
    weak var circle:CircleView!
    var transitionMode:CircularTransitionMode = .present
    var centerPoint:CGPoint!
    private var rockets:[Rocket]!
    

    enum CircularTransitionMode {
        case present, dismiss, pop
    }
    
    func setUp(circle:CircleView, duration:TimeInterval, centerPoint:CGPoint, _ rockets:[Rocket]? = nil) {
        self.circle = circle
        self.duration = duration
        self.centerPoint = centerPoint
        if let rockets = rockets {
            self.rockets = rockets
        }
    }
    
    fileprivate func hideSubviews(of view:UIView, _ boolean:Bool) {
        for view in view.subviews {
            view.isHidden = boolean
        }
    }
}

extension CircularTransition:UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
            if transitionMode == .present { //SHOWING
                if let toView = transitionContext.view(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from), let view = circle {
                
                    fromVC.viewWillDisappear(true)
                    
                    let translationY = (centerPoint.y -  toView.center.y) + toView.frame.height/2
                    
                    toView.transform = CGAffineTransform(translationX: 0, y: translationY)
                    toView.alpha = 0
                    view.layer.shadowOpacity = 0.0
                    toView.backgroundColor = circle?.backgroundColor
                    containerView.addSubview(toView)
                    
                
                    //Setting scale multiplier
                    let d = sqrt(pow(centerPoint.x, 2) + pow(centerPoint.y, 2))
                    let mult = d / (view.frame.height/2)
                    
                    
                    //Hiding subviews
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                        for view in view.subviews  {
                            view.alpha = 0
                        }
                        for rocket in self.rockets {
                            rocket.alpha = 0.0
                        }
                    }, completion: { (success) in
                        self.hideSubviews(of: view, true)
                    })
                    
                    
                    
                    //Scaling views
                    UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                        view.transform = CGAffineTransform(scaleX: mult, y: mult)
                        toView.alpha = 1.0
                        toView.transform = CGAffineTransform.identity
                    }, completion: { (success) in
                        transitionContext.completeTransition(success)
                        fromVC.viewDidDisappear(true)
                        view.isOpened = true
                    })
                }
            } else { //HIDING
                
                if let returningView = transitionContext.view(forKey: .from), let toVC = transitionContext.viewController(forKey: .to), let view = circle {
                    toVC.viewWillAppear(true)
                    
                    //Scaling views
                     let translationY = (centerPoint.y -  returningView.center.y) + returningView.frame.height/2
                    
                    UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                        view.transform = CGAffineTransform.identity
                        returningView.alpha = 0
                        returningView.transform = CGAffineTransform(translationX: 0, y: translationY)
                    }, completion: { (success) in
                        returningView.removeFromSuperview()
                        transitionContext.completeTransition(success)
                        toVC.viewDidAppear(true)
                        view.isOpened = false
                    })
                    
                    //Showing subviews with fade animation
                    hideSubviews(of: view, false)
                    UIView.animate(withDuration: 0.35, delay: 0.2, options: .curveEaseInOut, animations: {
                        for view in view.subviews {
                            view.alpha = 1.0
                        }
                        for rocket in self.rockets {
                            rocket.alpha = 1.0
                        }
                    }, completion: nil)
                }
            }
    }
}
