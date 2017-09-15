//
//  PriorityCircleOverallView.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 04.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class CircleView:UIView {
    var color:UIColor
    var taskType:TaskType
    var isOpened = false
    var progress:Double {
        didSet {
            let multiplier = CGFloat(progress/100)
           
            var subWidth:CGFloat = 0
            if self.subviews.count > 0 {
                for sub in self.subviews {
                    if let CVView = sub as? CircleView {
                        subWidth = CVView.frame.width
                    }
                }
            }

            let frame = CGRect(origin: self.frame.origin, size: CGSize(width: subWidth + multiplier * (self.frame.width - subWidth), height: subWidth + multiplier * (self.frame.size.height - subWidth)))
            
            let previousFrame = progressCircleView.frame
            progressCircleView.frame = frame
            progressCircleView.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            progressCircleView.layer.cornerRadius = progressCircleView.frame.width/2
            animateProgressIn(from: previousFrame)
        }
    }
    
    //Makes bounds circular. It is neccessary for tap gesture to distinguish which circle is tapped
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        return pow(center.x-point.x, 2) + pow(center.y - point.y, 2) <= pow(bounds.size.width/2, 2)
    }
    
    lazy var progressCircleView:UIView = {
        let view = UIView(frame: .zero)
        view.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.addSubview(view)
        view.backgroundColor = self.color.withAlphaComponent(0.5)
        view.layer.cornerRadius = view.frame.width/2
        self.sendSubview(toBack: view)
        return view
    }()

    init(frame:CGRect, color:UIColor, progress:Double, of type:TaskType) {
        self.color = color
        self.progress = progress
        self.taskType = type
        super.init(frame: frame)
        self.backgroundColor = UIColor.makeLighterColor(of: color, by: 0.2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateProgressIn(from frame:CGRect?) {
        
        if frame != nil {
            let w1 = frame?.width
            let w2 = progressCircleView.frame.width
            let multiplier = w1!/w2
            progressCircleView.transform = CGAffineTransform(scaleX: multiplier, y: multiplier)
        } else {
            progressCircleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.progressCircleView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

protocol PriorityCircleOverallDelegate {
    func tapped(on circle:CircleView)
}

class PriorityCircleOverallView: UIView {
    private var aimsCircleView:CircleView!
    private var objectivesCircleView:CircleView!
    private var targetsCircleView:CircleView!
    private var title:String!
    private var estimatedTime:TimeMeasurment!
    private var _state:PriorityCircleOverallState = .normal
    var state:PriorityCircleOverallState {
        set {
             _state = newValue
        }
        get {
            return _state
        }
    }
    var delegate:PriorityCircleOverallDelegate?
    
    enum PriorityCircleOverallState {
        case details
        case normal
    }
    
    
    
    // 🔥 FUNCTIONS 🔥
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setProgress(value:Double, for structure: TaskSplitterStructure) {
        switch structure {
        case .aims:
            aimsCircleView.progress = value
            break
        case .objectives:
            objectivesCircleView.progress = value
            break
        case .targets:
            targetsCircleView.progress = value
            break
        default:
            return
        }
    }
    
    public func setUp(for splitter:TaskSplitter) {
        self.backgroundColor = .clear
        self.layoutIfNeeded()
        aimsCircleView = CircleView(frame: .zero, color: splitter.priorityCircleColors[0], progress: 0, of: .aim)
        aimsCircleView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(aimsCircleView)
        
        objectivesCircleView = CircleView(frame: .zero, color: splitter.priorityCircleColors[1], progress: 0, of: .objective)
        objectivesCircleView.translatesAutoresizingMaskIntoConstraints = false
        aimsCircleView.addSubview(objectivesCircleView)
        
        targetsCircleView = CircleView(frame: .zero, color: splitter.priorityCircleColors[2], progress: 0, of: .target)
        targetsCircleView.translatesAutoresizingMaskIntoConstraints = false
        objectivesCircleView.addSubview(targetsCircleView)
        
        
        let ACVConstraints:[NSLayoutConstraint] = [
            aimsCircleView.widthAnchor.constraint(equalToConstant: self.frame.width),
            aimsCircleView.heightAnchor.constraint(equalToConstant: self.frame.width),
            NSLayoutConstraint(item: self.aimsCircleView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.aimsCircleView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        ]
    
        NSLayoutConstraint.activate(ACVConstraints)
        
        let const:CGFloat = self.frame.width/6
        let OCVConstraints:[NSLayoutConstraint] = [
            objectivesCircleView.topAnchor.constraint(equalTo: aimsCircleView.topAnchor, constant: const),
            objectivesCircleView.leadingAnchor.constraint(equalTo: aimsCircleView.leadingAnchor, constant: const),
            objectivesCircleView.trailingAnchor.constraint(equalTo: aimsCircleView.trailingAnchor, constant: -const),
            objectivesCircleView.bottomAnchor.constraint(equalTo: aimsCircleView.bottomAnchor, constant: -const)
        ]
        
        NSLayoutConstraint.activate(OCVConstraints)
        
        let TCVConstraints:[NSLayoutConstraint] = [
            targetsCircleView.topAnchor.constraint(equalTo: objectivesCircleView.topAnchor, constant: const),
            targetsCircleView.leadingAnchor.constraint(equalTo: objectivesCircleView.leadingAnchor, constant: const),
            targetsCircleView.trailingAnchor.constraint(equalTo: objectivesCircleView.trailingAnchor, constant: -const),
            targetsCircleView.bottomAnchor.constraint(equalTo: objectivesCircleView.bottomAnchor, constant: -const)
        ]
        
        NSLayoutConstraint.activate(TCVConstraints)
        
        //Corner radius
        aimsCircleView.layoutIfNeeded()
        aimsCircleView.layer.cornerRadius = aimsCircleView.frame.size.width/2
        objectivesCircleView.layer.cornerRadius = objectivesCircleView.frame.size.width/2
        targetsCircleView.layer.cornerRadius = targetsCircleView.frame.size.width/2
        
        
        //Tap gesture - Making 3 separate gesture recognizers is neccessary
        let aimsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (self.respondToTapGesture(sender:)))
        let objectivesTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (self.respondToTapGesture(sender:)))
        let targetsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (self.respondToTapGesture(sender:)))
        targetsCircleView.addGestureRecognizer(targetsTapGestureRecognizer)
        objectivesCircleView.addGestureRecognizer(objectivesTapGestureRecognizer)
        aimsCircleView.addGestureRecognizer(aimsTapGestureRecognizer)
    }
    
    //Respond function for Circle Views
    @objc func respondToTapGesture(sender:UITapGestureRecognizer) {
        if let view = sender.view as? CircleView {
            delegate?.tapped(on: view)
        }
    }
    
    
    
   
}
