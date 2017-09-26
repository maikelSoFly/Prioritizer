//
//  TrayMenuViewController.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 08.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

@objc protocol TrayMenuDelegate {
    //Implement layoutIfNeeded() in controller containing this tray menu
    func updateLayout()
    
    @objc optional func stateChanged(state:TrayMenuState)
    
    @objc optional func centerPosition(_ y:CGPoint)
}

@objc enum TrayMenuState: Int {
    case opened = 1
    case closed = 0
    case expanded = 2
    case hidden = 3
    case moving = 4
    case closing = 5
    case hiding = 6
    case showing = 7
}

enum TrayMenuPlacement {
    case top, bottom
}

enum TrayMenuStyle {
    case normal, discreet
}

class TrayMenuViewController: UIViewController {
    // Menu views
    
    // Essential
    private var label:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.text = "MENU"
        label.font = UIFont(name:"Helvetica-Bold", size: 14.0)
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        label.alpha = 1.0
        
        return label
    }()
    
    private lazy var actionButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.titleLabel?.text = ""
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.alpha = 1.0
        button.addTarget(self, action: #selector(self.cancelMenuEditing), for: .touchUpInside)
        
        return button
    }()
    
    // Customizable container for menu buttons
    private lazy var container:UICollectionView = {
        var flowLayout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.register(TrayMenuCollectionViewCell.self, forCellWithReuseIdentifier: "menuCell")
        view.dataSource = self
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 0
        
        return view
    }()
    
    
    private(set) var trayOpenedHeight:CGFloat!
    private var trayClosedHeight:CGFloat!
    private(set) var trayClosed:CGPoint!
    private(set) var trayOpened:CGPoint!
    private var trayHidden:CGPoint!
    private var trayFullyExpanded:CGPoint!
    private var cornerRadius:CGFloat = 10
    weak var constraint:NSLayoutConstraint!
    weak var delegate:TrayMenuDelegate! // Remember to always make it WEAK reference
    private var trayOriginalCenter:CGPoint!
    private var possibleDirectionState:IndicatorDirection = .downwards {
        didSet {
            changeDirectionIndicator()
        }
    }
    public var state:TrayMenuState = .closed {
        didSet {
        
            delegate.stateChanged?(state: state)
            
            if state == .expanded {
                label.text = "CANCEL"
                actionButton.setBackgroundImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
                return
            }
            
            if state == .opened {
                label.text = "CLOSE"
                possibleDirectionState = placement == .top ? .upwards : .downwards
            } else if state != .closing && state != .moving {
                label.text = "MENU"
                possibleDirectionState = placement == .top ? .downwards : .upwards
            }
        }
    }
    private var placement:TrayMenuPlacement = .top
    private var style:TrayMenuStyle = .normal
    fileprivate var menuControls = [TrayMenuButton]()
    fileprivate var containerInsets = UIEdgeInsets(top: 40, left: 30, bottom: 5, right: 30)
    fileprivate var itemsPerRow:CGFloat = 4
    public weak var dimView:DimView!
    private var vibrancyView:UIVisualEffectView!
    private var blurView:UIVisualEffectView!
    public var tintStyle: TrayMenuTintStyle = .normal  {
        didSet {
            container.reloadData()
        }
    }
    private var mySuperview:UIView!
    
    
    enum IndicatorDirection {
        case downwards, upwards
    }
    
    
    
    // 🔥 FUNCTIONS 🔥
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
        
        
        let blur = UIBlurEffect(style: .extraLight)
        blurView = UIVisualEffectView(effect: blur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        
        let vibrancy = UIVibrancyEffect(blurEffect: blur)
        vibrancyView = UIVisualEffectView(effect: vibrancy)
        vibrancyView.frame = view.bounds
        
        // Here adding subviews to have vibrancy appearance
        vibrancyView.contentView.addSubview(label)
        vibrancyView.contentView.addSubview(actionButton)
        vibrancyView.contentView.addSubview(container)
        
        blurView.contentView.addSubview(vibrancyView)
        
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.respondToPan(sender:))))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(sender:))))
    }
    
    deinit {
        print("💾 TrayMenuViewController deinitialized...")
    }
    
    @objc func tap(sender:UITapGestureRecognizer) {
        print("Tapped on tray")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setUpView(trayOpenedHeight:CGFloat, superview:UIView, trayClosedHeight:CGFloat, placement:TrayMenuPlacement, style:TrayMenuStyle) {
        self.mySuperview = superview
        self.trayFullyExpanded = CGPoint(x: superview.center.x, y: superview.center.y + (placement == .top ? -cornerRadius : cornerRadius))
        self.trayOpenedHeight = trayOpenedHeight
        self.trayClosedHeight = trayClosedHeight
        self.style = style
        
        self.placement = placement
        //Top style
        if placement == .top {
            trayHidden = CGPoint(x: superview.center.x, y: superview.center.y - view.frame.height)
            trayOpened = CGPoint(x: superview.center.x, y: superview.center.y - (view.frame.height - trayOpenedHeight))
            trayClosed = CGPoint(x: superview.center.x, y: superview.center.y - (view.frame.height - trayClosedHeight))
            
            if style == .discreet {
                blurView.alpha = 0.0
                view.addSubview(label)
                view.addSubview(actionButton)
            }
            
            setCenter(trayClosed)
            layoutControlls()
        } else { //Bottom style
            possibleDirectionState = .upwards
            
            trayHidden = CGPoint(x: superview.center.x, y: superview.center.y + view.frame.height)
            trayOpened = CGPoint(x: superview.center.x, y: superview.center.y + (view.frame.height - trayOpenedHeight))
            trayClosed = CGPoint(x: superview.center.x, y: superview.center.y + (view.frame.height - trayClosedHeight))
            
            if style == .discreet {
                blurView.alpha = 0.0
                view.addSubview(label)
                view.addSubview(actionButton)
            }

            setCenter(trayClosed)
            layoutControlls()
        }
    }
    
    func setUpContainer(insets:UIEdgeInsets, itemsPerRow:CGFloat) {
        self.containerInsets = insets
        self.itemsPerRow = itemsPerRow
    }
    
    func addControls(controls:[TrayMenuButton]) {
        menuControls.append(contentsOf: controls)
        container.reloadData()
    }
    
    private func layoutControlls() {
        if placement == .top {
            let image = #imageLiteral(resourceName: "arrowDown").withRenderingMode(.alwaysTemplate)
            actionButton.setBackgroundImage(image, for: .normal)
            
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            actionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
            label.bottomAnchor.constraint(equalTo: actionButton.topAnchor).isActive = true
        
            /// Container constraints
            container.topAnchor.constraint(equalTo: view.topAnchor, constant: (view.frame.height - trayOpenedHeight)).isActive = true
            container.bottomAnchor.constraint(equalTo: label.topAnchor).isActive = true
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            
        } else {
            let image = #imageLiteral(resourceName: "arrowUp").withRenderingMode(.alwaysTemplate)
            actionButton.setBackgroundImage(image, for: .normal)
            
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            actionButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            label.topAnchor.constraint(equalTo: actionButton.bottomAnchor).isActive = true
            
            /// Container constraints
            container.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.frame.height - trayOpenedHeight)).isActive = true
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
    }
    
    
    @objc func respondToPan(sender:UIPanGestureRecognizer) {
        if state != .expanded {
            let translation = sender.translation(in: view)
            let velocity = sender.velocity(in: view)
            switch sender.state {
            case .began:
                trayOriginalCenter = mySuperview.center
                break
            case .changed:
                move(with: translation)
                trayOriginalCenter = mySuperview.center
                break
            case .ended:
                stickToBound(with: velocity)
                break
            default:
                break
            }
        }
        
        sender.setTranslation(.zero, in: view)
    }
    
    
    
    private func setCenter(_ center:CGPoint) {
        mySuperview.center = center
        
        if placement == .top {
            if let dim = dimView {
                dim.frame.origin = mySuperview.frame.origin
            }
        } else {
            if let dim = dimView {
                dim.frame.origin = CGPoint(x: mySuperview.frame.origin.x, y: mySuperview.frame.origin.y - UIScreen.main.bounds.height)
            }
        }
        
        delegate.centerPosition?(center)
    }
    
    private func closeCustomView() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { 
            self.customView.alpha = 0.0
        }) { (success) in
            self.customView.removeFromSuperview()
            self.customView = nil
        }
    }
    
    @objc func cancelMenuEditing() {
        /// TODO
        if state != .expanded {
            use()
            return
        }
        
        state = .moving
        closeCustomView()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            if self.style == .discreet {
                self.blurView.alpha = 1.0
            }
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.setCenter(self.trayOpened)
            self.container.alpha = 1.0
        }, completion: { (success) in
            self.state = .opened
        })
    }
    
    @objc func use() {
        
        if state == .expanded {
            return
        }
        
        if state == .closed {
            state = .moving
            ///  OPEN
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                if self.style == .discreet {
                    self.blurView.alpha = 1.0
                }
                self.container.alpha = 1.0
                if self.dimView != nil {
                    self.dimView.alpha = 0.35
                }
            }, completion: nil)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
                self.setCenter(self.trayOpened)
            }, completion: { (success) in
                self.state = .opened
            })
            
        } else {
            state = .closing
            ///  CLOSE
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                if self.style == .discreet {
                    self.blurView.alpha = 0.0
                }
                self.container.alpha = 0.0
                if self.dimView != nil {
                    self.dimView.alpha = 0.0
                }
            }, completion: nil)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
                self.setCenter(self.trayClosed)
            }, completion: { (success) in
                self.state = .closed
            })
        }
    }
    
    private func move(with translation:CGPoint) {
        state = .moving
        
        if placement == .top {
            let y = (trayClosed.y ... trayFullyExpanded.y).clamp(trayOriginalCenter.y + translation.y)
            mySuperview.center = CGPoint(x: mySuperview.center.x, y: y)
        } else {
            let y = (trayFullyExpanded.y ... trayClosed.y).clamp(trayOriginalCenter.y + translation.y)
            mySuperview.center = CGPoint(x: mySuperview.center.x, y: y)
        }
        
        if state == .expanded && mySuperview.center.y <= trayOpened.y {
            state = .opened
        }

        
        // Fading dim view if exists
        if let dim = dimView {
            dim.frame.origin = placement == .bottom ? CGPoint(x: mySuperview.frame.origin.x, y: mySuperview.frame.origin.y - UIScreen.main.bounds.height) : mySuperview.frame.origin
            dim.alpha = (0 ... 0.35).clamp((mySuperview.center.y - trayClosed.y).remap(from1: 0, to1: trayOpened.y - trayClosed.y, from2: 0, to2: 0.35))
        }
        
        // Fading the container
        if state != .expanded {
            let alpha = (0 ... 1.0).clamp((mySuperview.center.y - trayClosed.y).remap(from1: 0, to1: trayOpened.y - trayClosed.y, from2: 0, to2: 1.0))
            if style == .discreet {
                blurView.alpha = alpha
            }
            container.alpha = alpha
            
        }
    }
    
    
    private func stickToBound(with velocity:CGPoint)  {
        if state == .expanded {
            let time = (0.1 ... 0.3).clamp(abs((trayOpened.y - mySuperview.center.y) / velocity.y))
            
            UIView.animate(withDuration: TimeInterval(time), delay: 0, options: .curveEaseInOut, animations: {
                self.setCenter(self.trayOpened)
                self.container.alpha = 1.0
            }, completion: { (success) in
                self.state = .opened
            })
            return
        }
        
        
        let multiplier:CGFloat = placement == .top ? 1 : -1
        if multiplier * velocity.y > 0 {
            let time = (0.3 ... 0.6).clamp(abs((mySuperview.center.y - trayOpened.y) / velocity.y))
            
            UIView.animate(withDuration: TimeInterval(time), delay: 0, options: .curveEaseInOut, animations: {
                if self.style == .discreet {
                    self.blurView.alpha = 1.0
                }
                self.container.alpha = 1.0
                if self.dimView != nil {
                    self.dimView.alpha = 0.35
                }
            }, completion: nil)
            
            UIView.animate(withDuration: TimeInterval(time), delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .curveEaseOut, animations: {
                self.setCenter(self.trayOpened)
            }, completion: {(success) in
                self.state = .opened
            })
        } else {
            let time = (0.3 ... 0.6).clamp(abs((mySuperview.center.y - trayClosed.y) / velocity.y))
            
            UIView.animate(withDuration: TimeInterval(time) - 0.1, delay: 0, options: .curveEaseInOut, animations: {
                if self.style == .discreet {
                    self.blurView.alpha = 0.0
                }
                self.container.alpha = 0.0
                if self.dimView != nil {
                    self.dimView.alpha = 0.0
                }
            }, completion: nil)
            
            UIView.animate(withDuration: TimeInterval(time), delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .curveEaseOut, animations: {
                self.setCenter(self.trayClosed)
            }, completion: {(success) in
                self.state = .closed
            })
        }
    }
    
    
    func hideMenuBar(_ boolean:Bool, animated:Bool) {
        //Validation
        if boolean && mySuperview.isHidden {
            print("❗Tried to hide already hidden menuBar")
            return
        }

        if !boolean && !mySuperview.isHidden {
            print("❗Tried to show already visible menuBar")
            return
        }
        
        if animated {
            if boolean { /// Animated hiding.
                state = .hiding
                UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut, animations: {
                    self.setCenter(self.trayHidden)
                    if let dim = self.dimView {
                        dim.alpha = 0.0
                    }
                    self.container.alpha = 0.0
                    if self.style == .discreet {
                        self.blurView.alpha = 0.0
                    }
                }, completion: { (success) in
                    self.mySuperview.isHidden = true
                    self.state = .hidden
                })
            } else { /// Animated showing.
                state = .showing
                mySuperview.isHidden = false
                UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: {
                    self.setCenter(self.trayClosed)
                }, completion: { (success) in
                    self.state = .closed
                })
            }
            
        } else {
            if boolean { /// Non-animated hiding.
                setCenter(trayHidden)
                mySuperview.isHidden = true
                self.state = .hidden
            } else { /// Non-animated showing.
                mySuperview.isHidden = false
                setCenter(trayClosed)
                self.state = .closed
            }
        }
    }
    
    
    private func changeDirectionIndicator() {
        let view = actionButton
        let direction = possibleDirectionState
        switch direction {
        case .upwards:
            let image = #imageLiteral(resourceName: "arrowUp").withRenderingMode(.alwaysTemplate)
            if view.backgroundImage(for: .normal) != image {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    view.alpha = 0
                }, completion: { (success) in
                    view.setBackgroundImage(image, for: .normal)
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                        view.alpha = 1.0
                    }, completion: nil)
                })
            }
            break
        case .downwards:
            let image = #imageLiteral(resourceName: "arrowDown").withRenderingMode(.alwaysTemplate)
            if view.backgroundImage(for: .normal) != image {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    view.alpha = 0
                }, completion: { (success) in
                    view.setBackgroundImage(image, for: .normal)
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                        view.alpha = 1.0
                    }, completion: nil)
                })
            }
            break
        }
    }
    
    private var customView:UIView!
    
    func expand(withView view:UIView) {
        customView = view
        customView.translatesAutoresizingMaskIntoConstraints = false
        self.vibrancyView.contentView.addSubview(customView)
        
        if placement == .top {
            customView.topAnchor.constraint(equalTo: mySuperview.topAnchor).isActive = true
            customView.bottomAnchor.constraint(equalTo: label.topAnchor).isActive = true
            customView.leadingAnchor.constraint(equalTo: mySuperview.leadingAnchor).isActive = true
            customView.trailingAnchor.constraint(equalTo: mySuperview.trailingAnchor).isActive = true
        } else {
            customView.topAnchor.constraint(equalTo: mySuperview.topAnchor).isActive = true
            customView.bottomAnchor.constraint(equalTo: label.topAnchor).isActive = true
            customView.leadingAnchor.constraint(equalTo: mySuperview.leadingAnchor).isActive = true
            customView.trailingAnchor.constraint(equalTo: mySuperview.trailingAnchor).isActive = true
        }
        
        
    
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { 
            self.setCenter(self.trayFullyExpanded)
            self.container.alpha = 0.0
        }, completion: { (success) in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: { 
                self.customView.alpha = 1.0
            }, completion: { (success) in
                self.state = .expanded
            })
            
        })
    }
    
}


// ⚡️ EXTENSIONS



extension TrayMenuViewController:UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuControls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! TrayMenuCollectionViewCell
        
        cell.configure(object: menuControls[indexPath.row], tintStyle: tintStyle) // TODO
        
        return cell
    }
}

extension TrayMenuViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let availableWidth = collectionView.frame.width - containerInsets.left - containerInsets.right
        
        let availableHeight = collectionView.frame.height - containerInsets.top - containerInsets.bottom
        
        let itemWidth = (availableWidth / itemsPerRow) - 10
        let itemHeight = (0 ... itemWidth+15).clamp((availableHeight / (CGFloat(menuControls.count) / itemsPerRow)) - 10)
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return containerInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
