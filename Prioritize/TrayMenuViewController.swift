//
//  TrayMenuViewController.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 08.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

protocol TrayMenuDelegate {
    //Implement layoutIfNeeded() in controller containing this tray menu
    func updateLayout()
    func stateChanged(state:TrayMenuState)
}

enum TrayMenuState {
    case opened, closed
}

class TrayMenuViewController: UIViewController {
    // Menu views
    
    // Essential
    private lazy var label:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "MENU"
        label.font = UIFont(name:"Helvetica-Bold", size: 14.0)
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        label.alpha = 0.5
        
        label.shadowColor = UIColor.black.withAlphaComponent(0.3)
        label.shadowOffset = CGSize(width: 0, height: 1)
        
        return label
    }()
    
    private lazy var actionButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        button.tintColor = .white
        button.titleLabel?.text = ""
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.alpha = 0.5
        button.addTarget(self, action: #selector(self.use), for: .touchUpInside)
        
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
        self.view.addSubview(view)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.alpha = 0
        
        
        return view
    }()
    

    private var trayOpenedMargin:CGFloat = 100.0
    private var trayClosedHeight:CGFloat = 100.0
    private var trayClosed:CGFloat!
    private var trayOpened:CGFloat!
    private var trayHidden:CGFloat!
    var constraint:NSLayoutConstraint!
    var delegate:TrayMenuDelegate!
    private var trayOriginalCenter:CGFloat!
    private var possibleDirectionState:IndicatorDirection = .downwards {
        didSet {
            changeDirectionIndicator()
        }
    }
    public var state:TrayMenuState = .closed {
        didSet {
            delegate.stateChanged(state: state)
            if state == .opened {
                possibleDirectionState = style == .top ? .upwards : .downwards
            } else {
                possibleDirectionState = style == .top ? .downwards : .upwards
            }
            
        }
    }
    private var style:TrayMenuStyle = .top
    fileprivate var menuControls = [UIControl]()
    fileprivate var containerInsets = UIEdgeInsets(top: 40, left: 40, bottom: 10, right: 40)
    fileprivate var itemsPerRow:CGFloat = 4
    
    enum IndicatorDirection {
        case downwards, upwards
    }
    
    enum TrayMenuStyle {
        case top, bottom
    }
    
  
    
    // 🔥 FUNCTIONS 🔥
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView(trayOpenedHeight:CGFloat, trayClosedHeight:CGFloat, constraint:NSLayoutConstraint!, style:TrayMenuStyle) {
        self.trayOpenedMargin = view.frame.height - trayOpenedHeight
        self.trayClosedHeight = trayClosedHeight
        self.constraint = constraint
        self.style = style
        //Top style
        if style == .top {
            self.constraint.constant = -view.frame.height + trayClosedHeight
            
            trayHidden = -view.frame.height
            trayOpened = -trayOpenedMargin
            
            trayClosed = constraint.constant
            layoutControlls()
        } else { //Bottom style
            possibleDirectionState = .upwards
            self.constraint.constant = -view.frame.height + trayClosedHeight
            
            trayHidden = -view.frame.height
            trayOpened = -trayOpenedMargin
            trayClosed = constraint.constant
            layoutControlls()
        }
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.respondToPan(sender:))))
    }
    
    func setUpContainer(insets:UIEdgeInsets, itemsPerRow:CGFloat) {
        self.containerInsets = insets
        self.itemsPerRow = itemsPerRow
    }
    
    func addControls(controls:[UIControl]) {
        menuControls.append(contentsOf: controls)
        container.reloadData()
    }
    
    private func layoutControlls() {
        if style == .top {
            let constraints:[NSLayoutConstraint] = [
                NSLayoutConstraint(item: actionButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: actionButton, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
                ]
            NSLayoutConstraint.activate(constraints)
            label.bottomAnchor.constraint(equalTo: actionButton.topAnchor).isActive = true
            
            let image = #imageLiteral(resourceName: "arrowDown").withRenderingMode(.alwaysTemplate)
            actionButton.setBackgroundImage(image, for: .normal)
            
            //Container constraints
            let containerConstraints:[NSLayoutConstraint] = [
                container.topAnchor.constraint(equalTo: view.topAnchor, constant: -self.trayOpened),
                container.bottomAnchor.constraint(equalTo: label.topAnchor),
                container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
            NSLayoutConstraint.activate(containerConstraints)
        } else {
            let constraints:[NSLayoutConstraint] = [
                NSLayoutConstraint(item: actionButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: actionButton, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
            ]
            NSLayoutConstraint.activate(constraints)
            label.topAnchor.constraint(equalTo: actionButton.bottomAnchor).isActive = true
            
            let image = #imageLiteral(resourceName: "arrowUp").withRenderingMode(.alwaysTemplate)
            actionButton.setBackgroundImage(image, for: .normal)
            
            //Container constraints
            
            let containerConstraints:[NSLayoutConstraint] = [
                container.topAnchor.constraint(equalTo: label.bottomAnchor),
                container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: self.trayOpened),
                container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
            NSLayoutConstraint.activate(containerConstraints)
        }
    }
    
    
    @objc func respondToPan(sender:UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        switch sender.state {
        case .began:
            trayOriginalCenter = constraint.constant
            break
        case .changed:
            move(with: translation)
            break
        case .ended:
            stickToBound(with: velocity)
            break
        default:
            break
        }
    }
    
    func use() {
        if state == .closed {
            //  OPEN
            constraint.constant = trayOpened
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
                self.delegate.updateLayout()
                self.container.alpha = 0.5
            }, completion: { (success) in
                self.state = .opened
            })
            
        } else {
            //  CLOSE
            constraint.constant = trayClosed
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
                self.delegate.updateLayout()
                self.container.alpha = 0.0
            }, completion: { (success) in
                self.state = .closed
            })
        }
    }
    
    func move(with translation:CGPoint) {
        if style == .top {
            let y = (-view.frame.height + trayClosedHeight ... 0).clamp(trayOriginalCenter + translation.y)
            self.constraint.constant = y
            
            
        } else {
            let y = (trayClosed ... 0).clamp(trayOriginalCenter - translation.y)
            self.constraint.constant = y
        }
        
        // Fading the container
        container.alpha = (constraint.constant - trayClosed).remap(from1: 0, to1: trayOpened - trayClosed, from2: 0, to2: 0.5)
    }
    
    
    func stickToBound(with velocity:CGPoint)  {
        let multiplier:CGFloat = style == .top ? 1 : -1
        if multiplier * velocity.y > 0 {
            let time = (0.3 ... 0.6).clamp(abs((constraint.constant - trayOpened) / velocity.y))
            
            constraint.constant = trayOpened
            
            UIView.animate(withDuration: TimeInterval(time), delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .curveEaseOut, animations: {
                self.delegate.updateLayout()
                self.container.alpha = 0.5
            }, completion: {(success) in
                self.state = .opened
            })
        } else {
            
            let time = (0.3 ... 0.6).clamp(abs((constraint.constant - trayClosed) / velocity.y))
            
            constraint.constant = trayClosed
            
            UIView.animate(withDuration: TimeInterval(time), delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .curveEaseOut, animations: {
                self.delegate.updateLayout()
                self.container.alpha = 0.0
            }, completion: {(success) in
                self.state = .closed
            })
        }
    }
    
    func hideMenuBar(_ boolean:Bool, animated:Bool) {
        //Validation
        if boolean && view.isHidden {
            print("❗Tried to hide already hidden menuBar")
            return
        }

        if !boolean && !view.isHidden {
            print("❗Tried to show already visible menuBar")
            return
        }

        if !boolean {
            view.isHidden = false
            constraint.constant = trayClosed
        } else {
            constraint.constant = trayHidden
        }

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.delegate.updateLayout()
            }, completion: { (success) in
                if boolean {
                    self.possibleDirectionState = self.style == .top ? .downwards : .upwards
                    self.changeDirectionIndicator()
                    self.view.isHidden = true
                    self.container.alpha = 0.0
                }
            })
        } else {
            self.delegate.updateLayout()
            if boolean {
                self.possibleDirectionState = style == .top ? .downwards : .upwards
                self.changeDirectionIndicator()
                self.view.isHidden = true
                self.container.alpha = 0.0
            }
        }
    }
    
    
    func changeDirectionIndicator() {
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
                        view.alpha = 0.5
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
                        view.alpha = 0.5
                    }, completion: nil)
                })
            }
            break
        }
    }
}

extension TrayMenuViewController:UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuControls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! TrayMenuCollectionViewCell
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        cell.configure() // TODO
        
        return cell
    }
}

extension TrayMenuViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let availableWidth = collectionView.frame.width - containerInsets.left - containerInsets.right
        
        let availableHeight = collectionView.frame.height - containerInsets.top - containerInsets.bottom
        
        let itemWidth = (availableWidth / itemsPerRow) - 10
        let itemHeight = (availableHeight / (CGFloat(menuControls.count) / itemsPerRow)) - 10
        
        let itemSize = itemWidth < itemHeight ? itemWidth : itemHeight
        
        
        return CGSize(width: itemSize, height: itemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return containerInsets
    }
    
    
    
    
    
  
    
    
}
