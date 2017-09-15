//
//  ViewController.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 04.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class OverallViewController: UIViewController {
    @IBOutlet weak var priorityCircleOverallView: PriorityCircleOverallView!
    @IBOutlet weak var menuBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuBarView: UIView!
    
    fileprivate var menuBar:TrayMenuViewController!
    private var taskSplitter:TaskSplitter?
    fileprivate var transition:CircularTransition = CircularTransition()
    fileprivate let transitionDuration:TimeInterval = 0.2
    fileprivate var gradientLayer:CAGradientLayer!
    @IBOutlet weak var testButton: UIButton!
    
    @IBAction func handleTestButton(_ sender: UIButton) {
        if priorityCircleOverallView.state == .normal {
            let a = Int.randomInt(min: 0, max: 100)
            let b = Int.randomInt(min: 0, max: 100)
            let c = Int.randomInt(min: 0, max: 100)
            
            priorityCircleOverallView.setProgress(value: Double(a), for: .aims)
            priorityCircleOverallView.setProgress(value: Double(b), for: .objectives)
            priorityCircleOverallView.setProgress(value: Double(c), for: .targets)
        }
    }
    
    
    
    // 🔥 FUNCTIONS 🔥
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        
        // Initializing Task Splitter.
        view.bringSubview(toFront: priorityCircleOverallView)
        priorityCircleOverallView.delegate = self
        taskSplitter = TaskSplitter(title: "Moving out to countryside", estimatedTime: TimeMeasurment(value: 6, unit:CFCalendarUnit.year), priorityCircleColors: UIColor.defaultAppColors())
        priorityCircleOverallView.setUp(for: taskSplitter!)
        
        // Tray menu.
        view.bringSubview(toFront: menuBarView)
        menuBar.setUpView(trayOpenedHeight: 250, trayClosedHeight: 100, constraint: menuBarTopConstraint, style: .top)
        
        let controls:[UIControl] = [
            UIButton(),
            UIButton(),
            UIButton(),
            UIButton(),
            UIButton(),
            UIButton(),
            UIButton(),
            UIButton()
        ]
        
        menuBar.addControls(controls: controls)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TrayMenuSegue" {
            menuBar = segue.destination as? TrayMenuViewController
            menuBar.delegate = self
            return
        }
        
        // For circular transision
        let vc = segue.destination
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
    }
}



// ⚡️ EXTENSIONS ⚡️



extension OverallViewController:PriorityCircleOverallDelegate {
    func tapped(on circle: CircleView) {
        let type = circle.taskType
        transition.setUp(circle: circle, duration: 0.1)
        
        switch type {
        case .aim:
            performSegue(withIdentifier: "AimsDetailsSegue", sender: self)
            break
        case .objective:
            performSegue(withIdentifier: "ObjectivesDetailsSegue", sender: self)
            break
        case .target:
            performSegue(withIdentifier: "TargetsDetailsSegue", sender: self)
            break
        default:
            print("❗Tapped on circle of type: none")
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if UIDevice.current.orientation.isLandscape {
            menuBar.hideMenuBar(true, animated: true)
        } else {
            menuBar.hideMenuBar(false, animated: true)
        }
    }

}

extension OverallViewController:UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // Init code before dismissing view.
        menuBar.hideMenuBar(false, animated: true)
        transition.transitionMode = .dismiss
        
        return transition
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
       
        // Init code before presenting view.
        menuBar.hideMenuBar(true, animated: true)
        transition.transitionMode = .present
        
        return transition
    }
}

extension OverallViewController:TrayMenuDelegate {
    func updateLayout() {
        view.layoutIfNeeded()
    }
    
    func stateChanged(state: TrayMenuState) {
        // opened / closed
    }
}


