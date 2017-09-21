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
            
            priorityCircleOverallView.setProgress(value: Double(a), for: .urgents)
            priorityCircleOverallView.setProgress(value: Double(b), for: .moderates)
            priorityCircleOverallView.setProgress(value: Double(c), for: .optionals)
        }
    }
    fileprivate var dimView:DimView!
    private var timer:Timer!
    private var timerInterval:TimeInterval = 60  // "It's 5 min!" ~Captain Obvious
    
    
    
    // 🔥 FUNCTIONS 🔥
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        
        /// Test button
        testButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        testButton.layer.cornerRadius = 8
        testButton.layer.masksToBounds = true
        testButton.tintColor = #colorLiteral(red: 1, green: 0.4082366228, blue: 0.3242999315, alpha: 1)
        testButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 12)
        
        
        /// Initializing Task Splitter.
        view.bringSubview(toFront: priorityCircleOverallView)
        priorityCircleOverallView.delegate = self
        taskSplitter = TaskSplitter(title: "Main Task Splitter", priorityCircleColors: UIColor.defaultAppColors())
        priorityCircleOverallView.setUp(for: taskSplitter!)
        
        /// Tray menu.
        view.bringSubview(toFront: menuBarView)
    
//🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰
//   Process of adding Tray Menu with buttons and dim.

        menuBar.setUpView(trayOpenedHeight: 250, trayClosedHeight: 100, constraint: menuBarTopConstraint, style: .top)

        let btn1 = TrayMenuButton(image: #imageLiteral(resourceName: "add"), description: "Add Task")
        let btn2 = TrayMenuButton(image: #imageLiteral(resourceName: "flame"), description: "Hot")
        let btn3 = TrayMenuButton(image: #imageLiteral(resourceName: "shuffle"), description: "Shuffle")
        let btn4 = TrayMenuButton(image: #imageLiteral(resourceName: "burger"), description: "Meal")
        let btn5 = TrayMenuButton(image: #imageLiteral(resourceName: "image"), description: "Images")
        let btn6 = TrayMenuButton(image: #imageLiteral(resourceName: "lens"), description: "Camera")
        let btn7 = TrayMenuButton(image: #imageLiteral(resourceName: "bitcoin"), description: "Wallet")
        let btn8 = TrayMenuButton(image: #imageLiteral(resourceName: "profile"), description: "Profile")
        let arr = [btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8]

        menuBar.addControls(controls: arr)
        
        /// Button targets
        
        btn1.addTarget(self, action: #selector(addTask(sender:)), for: .touchUpInside)
        // ...

        
        /// Dim View

        dimView = DimView(in: self.view, forTrayView: menuBarView, withStyle: .top)
        menuBar.dimView = dimView
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(respondToDimViewTap(sender:))))

//🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰
        

        /// Scheduled Timer
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(self.updateTimer(timer:)), userInfo: nil, repeats: true)
    }

    deinit {
        print("💾 OverallViewController deinitialized...")
    }
    
    @objc func updateTimer(timer:Timer) {
        print("\n⏱ Timer update!")
        
        taskSplitter?.reloadData(for: .optional)
        taskSplitter?.reloadData(for: .moderate)
        taskSplitter?.reloadData(for: .urgent)
    }
    
    @objc func respondToDimViewTap(sender:UITapGestureRecognizer) {
        menuBar.use()
    }
    
    @objc func addTask(sender:TrayMenuButton) {
        menuBar.expand()
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
        
        /// For circular transision
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
        case .urgent:
            performSegue(withIdentifier: "UrgentTasksSegue", sender: self)
            break
        case .moderate:
            performSegue(withIdentifier: "ModerateTasksSegue", sender: self)
            break
        case .optional:
            performSegue(withIdentifier: "OptionalTasksSegue", sender: self)
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
        
        /// Init code before dismissing view.
        menuBar.hideMenuBar(false, animated: true)
        transition.transitionMode = .dismiss
        
        return transition
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
       
        /// Init code before presenting view.
        menuBar.hideMenuBar(true, animated: true)
        transition.transitionMode = .present
        
        return transition
    }
}

extension OverallViewController:TrayMenuDelegate {
    func updateLayout() {
        view.layoutIfNeeded()
    }
}


