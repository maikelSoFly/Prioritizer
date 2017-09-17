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
    fileprivate var dimView:DimView!
    
    
    
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
        
        
        
        let btn1 = TrayMenuButton(image: #imageLiteral(resourceName: "box"), description: "Folders")
        let btn2 = TrayMenuButton(image: #imageLiteral(resourceName: "flame"), description: "Hot")
        let btn3 = TrayMenuButton(image: #imageLiteral(resourceName: "shuffle"), description: "Shuffle")
        let btn4 = TrayMenuButton(image: #imageLiteral(resourceName: "burger"), description: "Meal")
        let btn5 = TrayMenuButton(image: #imageLiteral(resourceName: "image"), description: "Images")
        let btn6 = TrayMenuButton(image: #imageLiteral(resourceName: "lens"), description: "Camera")
        let btn7 = TrayMenuButton(image: #imageLiteral(resourceName: "bitcoin"), description: "Wallet")
        let btn8 = TrayMenuButton(image: #imageLiteral(resourceName: "profile"), description: "Profile")
        let arr = [btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8]
        
        menuBar.addControls(controls: arr)
        
        for btn in arr {
            btn.addTarget(self, action: #selector(test(sender:)), for: .touchUpInside)
        }
        
        
        // Dim View
        
        dimView = DimView(in: self.view, forPopUpView: menuBarView, withStyle: .top)
        menuBar.dimView = dimView
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(respondToDimViewTap(sender:))))
    }
    
    @objc func respondToDimViewTap(sender:UITapGestureRecognizer) {
        menuBar.use()
    }
    
    @objc func test(sender:TrayMenuButton) {
        print("🍏", sender.buttonDescription)
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
        
    }
    
    func verticalPosition(_ y:CGFloat) {
        
    }
}


