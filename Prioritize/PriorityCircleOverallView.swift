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
    
    // "Makes" bounds circular. It is neccessary for tap gesture to distinguish which circle is tapped
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        return pow(center.x-point.x, 2) + pow(center.y - point.y, 2) <= pow(bounds.size.width/2, 2)
    }
    
    lazy var progressCircleView:RadialGradientView = {
        let inColor = UIColor.makeLighterColor(of: self.color, by: -0.3).withAlphaComponent((self.taskType == .urgent || self.taskType == .optional ? 0.2 : 1.0))
        let outColor = UIColor.makeLighterColor(of: self.color, by: 0.2).withAlphaComponent( (self.taskType == .urgent || self.taskType == .optional ? 0.25 : 0.8) )
        
        let view = RadialGradientView(frame: .zero, insideColor: inColor, outsideColor: outColor)
        view.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        view.layer.masksToBounds = true
        self.addSubview(view)
        view.backgroundColor = .clear
        view.layer.cornerRadius = view.frame.width/2
        view.layer.borderColor = self.taskType == .urgent ? UIColor.darkGray.withAlphaComponent(0.5).cgColor : UIColor.lightGray.withAlphaComponent(0.5).cgColor
        view.layer.borderWidth = 0.0
        self.sendSubview(toBack: view)
        return view
    }()

    init(frame:CGRect, color:UIColor, progress:Double, of type:TaskType) {
        self.color = color
        self.progress = progress
        self.taskType = type
        super.init(frame: frame)
        self.backgroundColor = color
        
        dropShadow()
    }
    
    func dropShadow() {
        if taskType == .optional {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.35
            layer.shadowOffset = CGSize.zero
            layer.shadowRadius = 10
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
        } else {
            /// Shadow for urgent & moderate tiers.
        }
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
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
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
    private var _state:PriorityCircleOverallState = .normal
    var protrudingWidth:Double = 0
    var state:PriorityCircleOverallState {
        set {
             _state = newValue
        }
        get {
            return _state
        }
    }
    var delegate:PriorityCircleOverallDelegate?
    /// Colors of tiers; [urgent, moderate, optional]
    private let colors = [#colorLiteral(red: 0.142003311, green: 0.1434092844, blue: 0.1434092844, alpha: 1), #colorLiteral(red: 0.7456802726, green: 0.06953835487, blue: 0.2190275192, alpha: 1), #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1).withAlphaComponent(0.6)]
    
    
    
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
        case .urgents:
            aimsCircleView.progress = value
            break
        case .moderates:
            objectivesCircleView.progress = value
            break
        case .optionals:
            targetsCircleView.progress = value
            break
        default:
            return
        }
    }
    
    public func setUp(for splitter:TaskSplitter) {
        self.backgroundColor = .clear
       
        aimsCircleView = CircleView(frame: .zero, color: colors[2], progress: 0, of: .optional)
        aimsCircleView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(aimsCircleView)
        
        objectivesCircleView = CircleView(frame: .zero, color: colors[1], progress: 0, of: .moderate)
        objectivesCircleView.translatesAutoresizingMaskIntoConstraints = false
        aimsCircleView.addSubview(objectivesCircleView)
        
        targetsCircleView = CircleView(frame: .zero, color: colors[0], progress: 0, of: .urgent)
        targetsCircleView.translatesAutoresizingMaskIntoConstraints = false
        objectivesCircleView.addSubview(targetsCircleView)
        
      
        
        let const:CGFloat = self.frame.width / 3
        protrudingWidth = Double(const/2)
        print(const)
        let circlesConstraints:[NSLayoutConstraint] = [
            aimsCircleView.widthAnchor.constraint(equalTo: self.widthAnchor),
            aimsCircleView.heightAnchor.constraint(equalTo: self.heightAnchor),
            aimsCircleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            aimsCircleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            objectivesCircleView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -const),
            objectivesCircleView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -const),
            objectivesCircleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            objectivesCircleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            targetsCircleView.widthAnchor.constraint(equalTo: objectivesCircleView.widthAnchor, constant: -const),
            targetsCircleView.heightAnchor.constraint(equalTo: objectivesCircleView.heightAnchor, constant: -const),
            targetsCircleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            targetsCircleView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
    
        NSLayoutConstraint.activate(circlesConstraints)
        
        
        
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
    
    var rocketsStartPosition = [CGPoint]() {
        didSet {
            for position in rocketsStartPosition {
                let origin = CGPoint(x: position.x - 8, y: position.y - 8)
                let frame = CGRect(origin: origin, size: CGSize(width: 16, height: 16))
                let imageView = UIImageView(frame: frame)
                imageView.image = #imageLiteral(resourceName: "circle2")
                
                
                self.aimsCircleView.insertSubview(imageView, belowSubview: objectivesCircleView)
            }
        }
    }
    
    var centerRocketPosition:CGPoint!
    
    func centerRocketPositionRelative(to view:UIView) -> CGPoint {
        return self.convert(centerRocketPosition, to: view)
    }
    
    
//    enum CircleSides {
//        case left, center, right
//    }
    
    /// Sets rockets positions relative to PCOView and returns this positions relative to given view.
    public func setRocketsStartPositions(relativeToView view:UIView) -> [CGPoint] {
        var positions = [CGPoint]()
        let radius = Double(aimsCircleView.frame.width / 2) - 9
        let center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        /// cos(𝚹) = x / r  ==>  x = r * cos(𝚹)
        /// sin(𝚹) = y / r  ==>  y = r * sin(𝚹)
        
        /// MARK: LEFT-SIDE rockets positions
        for i in stride(from: 180, to: 266, by: 5) {

            /// radians = degrees * π / 180
            let radians = Double(i) * Double.pi / 180

            let x = Double(center.x) + radius * cos(radians)
            if x > protrudingWidth {
                let y = Double(center.y) + radius * sin(radians)

                let point = CGPoint(x: x, y: y)
                rocketsStartPosition.append(point)
                positions.append(self.convert(point, to: view))
            }
        }
        
        /// MARK: RIGHT-SIDE rockets positions
        for i in stride(from: 275, to: 360, by: 5) {
            
            /// radians = degrees * π / 180
            let radians = Double(i) * Double.pi / 180
            
            let x = Double(center.x) + radius * cos(radians)
            if x < Double(self.frame.width) - protrudingWidth {
                let y = Double(center.y) + radius * sin(radians)
                
                let point = CGPoint(x: x, y: y)
                rocketsStartPosition.append(point)
                positions.append(self.convert(point, to: view))
            }
        }
        
        /// MARK: CENTER rocket position
        for i in stride(from: 270, to: 271, by: 5) {
            /// radians = degrees * π / 180
            let radians = Double(i) * Double.pi / 180
            
            let x = Double(center.x) + radius * cos(radians)
            let y = Double(center.y) + radius * sin(radians)
            
            let point = CGPoint(x: x, y: y)
            centerRocketPosition = point
            rocketsStartPosition.append(point)
            positions.append(self.convert(point, to: view))
        }
        
        
        return positions
    }
    
    
    
   
}
