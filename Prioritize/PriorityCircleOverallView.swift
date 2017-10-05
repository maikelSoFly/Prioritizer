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
    
    
    // "Makes" bounds circular. It is neccessary for tap gesture to distinguish which circle is tapped
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        return pow(center.x-point.x, 2) + pow(center.y - point.y, 2) <= pow(bounds.size.width/2, 2)
    }
    
    lazy var sectionCircleView:RadialGradientView = {
        let inColor:UIColor, outColor:UIColor
        
        if taskType == .urgent {
            inColor = .black
            outColor = UIColor.makeLighterColor(of: color, by: 0.03)
        } else {
            inColor = UIColor.makeLighterColor(of: self.color, by: -0.3).withAlphaComponent( self.taskType == .optional ? 0.2 : 1.0 )
            outColor = UIColor.makeLighterColor(of: self.color, by: 0.2).withAlphaComponent(  self.taskType == .optional ? 0.25 : 0.8 )
        }
        
        let frame = setFrameForSectionCircle()
        let view = RadialGradientView(frame: frame, insideColor: inColor, outsideColor: outColor)
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
    
    private func setFrameForSectionCircle() -> CGRect {
        var SCFrame:CGRect
        
        if taskType == .urgent {
            return CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height))
        } else {
            for subview in subviews {
                if let sub = subview as? CircleView {
                    let difference = (sub.frame.height - frame.height) / 2
                    SCFrame = CGRect(origin: frame.origin, size: CGSize(width: frame.width+difference, height: frame.height+difference))
                
                    return SCFrame
                }
            }
        }
       
        return .zero
    }

    init(frame:CGRect, color:UIColor, of type:TaskType) {
        self.color = color
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
    
    
    public func showSectionCircleInside(bool:Bool) {
        if bool {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.sectionCircleView.transform = CGAffineTransform.identity
            }, completion: nil)
        } else { /// Non-animated for optimalization purposes.
            sectionCircleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }
    }
    
}






protocol PriorityCircleOverallDelegate {
    func tapped(on circle:CircleView)
}

class PriorityCircleOverallView: UIView {
    private var ergosphereCircleView:CircleView!
    private var eventHorizonCircleView:CircleView!
    private var singularityCircleView:CircleView!
    private var title:String!
    private var _state:PriorityCircleOverallState = .normal
    var protrudingWidth:Double = 0
    var isLaidout = false
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
    var rocketsStartPositions = [CGPoint]() 
        
    
    var centerRocketStartPosition:CGPoint!
    
    
    enum PriorityCircleOverallState {
        case details
        case normal
    }
    
    
    
    // 🔥 FUNCTIONS 🔥
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func showSectionCircles(bool:Bool) {
        ergosphereCircleView.showSectionCircleInside(bool: bool)
        eventHorizonCircleView.showSectionCircleInside(bool: bool)
        singularityCircleView.showSectionCircleInside(bool: bool)
    }
    
    public func setUp(for splitter:TaskSplitter) {
        self.backgroundColor = .clear
       
        ergosphereCircleView = CircleView(frame: .zero, color: colors[2], of: .optional)
        ergosphereCircleView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(ergosphereCircleView)
        
        eventHorizonCircleView = CircleView(frame: .zero, color: colors[1], of: .moderate)
        eventHorizonCircleView.translatesAutoresizingMaskIntoConstraints = false
        ergosphereCircleView.addSubview(eventHorizonCircleView)
        
        singularityCircleView = CircleView(frame: .zero, color: colors[0], of: .urgent)
        singularityCircleView.translatesAutoresizingMaskIntoConstraints = false
        eventHorizonCircleView.addSubview(singularityCircleView)
        
      
        
        let const:CGFloat = self.frame.width / 3
        protrudingWidth = Double(const/2)
    
        let circlesConstraints:[NSLayoutConstraint] = [
            ergosphereCircleView.widthAnchor.constraint(equalTo: self.widthAnchor),
            ergosphereCircleView.heightAnchor.constraint(equalTo: self.heightAnchor),
            ergosphereCircleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ergosphereCircleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            eventHorizonCircleView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -const),
            eventHorizonCircleView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -const),
            eventHorizonCircleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            eventHorizonCircleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            singularityCircleView.widthAnchor.constraint(equalTo: eventHorizonCircleView.widthAnchor, constant: -const),
            singularityCircleView.heightAnchor.constraint(equalTo: eventHorizonCircleView.heightAnchor, constant: -const),
            singularityCircleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            singularityCircleView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
    
        NSLayoutConstraint.activate(circlesConstraints)
        
        
        
        //MARK: - Corner radius
        ergosphereCircleView.layoutIfNeeded()
        ergosphereCircleView.layer.cornerRadius = ergosphereCircleView.frame.size.width/2
        eventHorizonCircleView.layer.cornerRadius = eventHorizonCircleView.frame.size.width/2
        singularityCircleView.layer.cornerRadius = singularityCircleView.frame.size.width/2
        
        //MARK: - SectionCircleViews layout
        ergosphereCircleView.sectionCircleView.layoutIfNeeded()
        eventHorizonCircleView.sectionCircleView.layoutIfNeeded()
        singularityCircleView.sectionCircleView.layoutIfNeeded()
        
        
        
        //Tap gesture - Making 3 separate gesture recognizers is neccessary
        let aimsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (self.respondToTapGesture(sender:)))
        let objectivesTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (self.respondToTapGesture(sender:)))
        let targetsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (self.respondToTapGesture(sender:)))
        singularityCircleView.addGestureRecognizer(targetsTapGestureRecognizer)
        eventHorizonCircleView.addGestureRecognizer(objectivesTapGestureRecognizer)
        ergosphereCircleView.addGestureRecognizer(aimsTapGestureRecognizer)
    }
    
    //Respond function for Circle Views
    @objc func respondToTapGesture(sender:UITapGestureRecognizer) {
        if let view = sender.view as? CircleView {
            delegate?.tapped(on: view)
        }
    }
    
    
    
    /// 🚀 Just rockets things 🚀
    
    func getCenterRocketStartPositionRelative(to view:UIView) -> CGPoint {
        return self.convert(centerRocketStartPosition, to: view)
    }
    
    func getRocketsStartPositionsRelative(to view:UIView) -> [CGPoint] {
        var arr = [CGPoint]()
        
        for position in rocketsStartPositions {
            arr.append(self.convert(position, to: view))
        }
        
        return arr
    }
    
    
    /// Sets rockets positions relative to this view.
    public func setRocketsStartPositions() {
        let radius = Double(ergosphereCircleView.frame.width / 2)
        let center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        /// cos(𝚹) = x / r  ==>  x = r * cos(𝚹)
        /// sin(𝚹) = y / r  ==>  y = r * sin(𝚹)
        
        /// MARK: LHS rockets positions
        for i in stride(from: 180, to: 266, by: 5) {

            /// radians = degrees * π / 180
            let radians = Double(i) * Double.pi / 180

            let x = Double(center.x) + radius * cos(radians)
            if x > protrudingWidth {
                let y = Double(center.y) + radius * sin(radians)

                let point = CGPoint(x: x, y: y)
                rocketsStartPositions.append(point)
            }
        }
        
        /// MARK: RHS rockets positions
        for i in stride(from: 275, to: 360, by: 5) {
      
            let radians = Double(i) * Double.pi / 180
            
            let x = Double(center.x) + radius * cos(radians)
            if x < Double(self.frame.width) - protrudingWidth {
                let y = Double(center.y) + radius * sin(radians)
                
                let point = CGPoint(x: x, y: y)
                rocketsStartPositions.append(point)
            }
        }
        
        /// MARK: CENTER rocket position

        let radians = 270 * Double.pi / 180
        
        let x = Double(center.x) + radius * cos(radians)
        let y = Double(center.y) + radius * sin(radians)
        
        let point = CGPoint(x: x, y: y)
        centerRocketStartPosition = point
        rocketsStartPositions.append(point)
    }
    
    func addRocket(rocket:Rocket) {
        self.ergosphereCircleView.insertSubview(rocket, belowSubview: eventHorizonCircleView)
    }
    
    
    
   
}
