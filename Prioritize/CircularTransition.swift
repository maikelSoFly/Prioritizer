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
    

    enum CircularTransitionMode {
        case present, dismiss, pop
    }
    
    func setUp(circle:CircleView, duration:TimeInterval) {
        self.circle = circle
        self.duration = duration
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
                if let presentedView = transitionContext.view(forKey: .to), let view = circle {
                    //presentedView.center = view.center
                    presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    presentedView.alpha = 0
                    presentedView.backgroundColor = circle?.backgroundColor
                    containerView.addSubview(presentedView)
                    
                    /// Inverting colors of target view controller's views based on background color.
                    switch circle.taskType {
                    case .optional:
                        (transitionContext.viewController(forKey: .to) as? OptionalTasksViewController)?.makeViewsVisibleAgainstBackground(color: (circle.backgroundColor)!)
                        break
                    case .moderate:
                        (transitionContext.viewController(forKey: .to) as? ModerateTasksViewController)?.makeViewsVisibleAgainstBackground(color: circle.backgroundColor!)
                        break
                    case .urgent:
                        (transitionContext.viewController(forKey: .to) as? UrgentTasksViewController)?.makeViewsVisibleAgainstBackground(color: (circle.backgroundColor)!)
                        break
                    default:
                        return
                    }
                    
                    
                
                    //Setting scale multiplier
                    let displayHeight = UIScreen.main.bounds.size.height
                    let displayWidth = UIScreen.main.bounds.size.width
                    
                    let multiplier = displayWidth < displayHeight ? (displayHeight * 1.5) / view.bounds.size.height :
                        (displayWidth * 1.5) / view.bounds.size.width
                    
                    //Hiding subviews
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                        for view in view.subviews {
                            view.alpha = 0
                        }
                    }, completion: { (success) in
                        self.hideSubviews(of: view, true)
                        view.isOpened = true
                    })
                    
                    //Scaling views
                    UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                        view.transform = CGAffineTransform(scaleX: multiplier, y: multiplier)
                        presentedView.alpha = 1.0
                        presentedView.transform = CGAffineTransform.identity
                    }, completion: { (success) in
                        transitionContext.completeTransition(success)
                    })
                }
            } else { //HIDING
                
                if let returningView = transitionContext.view(forKey: .from), let view = circle {
                    
                    //Scaling views
                    UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                        view.transform = CGAffineTransform.identity
                        returningView.alpha = 0
                        returningView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                        
                    }, completion: { (success) in
                        returningView.removeFromSuperview()
                        transitionContext.completeTransition(success)
                
                    })
                    
                    //Showing subviews with fade animation
                    hideSubviews(of: view, false)
                    UIView.animate(withDuration: 0.35, delay: 0.2, options: .curveEaseInOut, animations: {
                        for view in view.subviews {
                            view.alpha = 1.0
                        }
                    }, completion: { (success) in
                        view.isOpened = false
                    })
                }
            }
        
    }
}
