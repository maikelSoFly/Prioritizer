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
    @IBOutlet weak var menuBarView: UIView!
    
    fileprivate var menuBar:TrayMenuViewController!
    private var taskSplitter:TaskSplitter?
    fileprivate var transition:CircularTransition = CircularTransition()
    fileprivate let transitionDuration:TimeInterval = 0.2
    fileprivate var gradientLayer:CAGradientLayer!
    
    @objc private func handleShowProgress(value:Double) {
        if priorityCircleOverallView.state == .normal {
//            let a = Int.randomInt(min: 0, max: 100)
//            let b = Int.randomInt(min: 0, max: 100)
//            let c = Int.randomInt(min: 0, max: 100)
            
            
            priorityCircleOverallView.setProgress(value: value, for: .urgents)
            priorityCircleOverallView.setProgress(value: value, for: .moderates)
            priorityCircleOverallView.setProgress(value: value, for: .optionals)
        }
    }
    fileprivate var dimView:DimView!
    private var timer:Timer!
    private var timerInterval:TimeInterval = 60  // "It's 5 min!" ~Captain Obvious
    private var isStatusBarHidden:Bool = false {
        didSet{
            UIView.animate(withDuration: 0.5) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    private var rocketsStartPositions = [CGPoint]()
    
    
    
    // 🔥 FUNCTIONS 🔥
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        
        
        /// Initializing Task Splitter.
        view.bringSubview(toFront: priorityCircleOverallView)
        
        priorityCircleOverallView.translatesAutoresizingMaskIntoConstraints = false
        priorityCircleOverallView.centerYAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        priorityCircleOverallView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        /// 2/3 * PCOV.frame.width = ScreenWidth  ==>  PCOV.frame.width = 3/2 ScreenWidth
        priorityCircleOverallView.widthAnchor.constraint(equalToConstant: (3/2) * UIScreen.main.bounds.width).isActive = true
        priorityCircleOverallView.heightAnchor.constraint(equalToConstant: (3/2) * UIScreen.main.bounds.width).isActive = true
        view.layoutIfNeeded()
        
        priorityCircleOverallView.isUserInteractionEnabled = true
        priorityCircleOverallView.delegate = self
        taskSplitter = TaskSplitter(title: "Main Task Splitter", priorityCircleColors: UIColor.defaultAppColors())
        priorityCircleOverallView.setUp(for: taskSplitter!)
        
        
        /// Tray menu.
        view.bringSubview(toFront: menuBarView)
    
//🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰
//   Process of adding Tray Menu with buttons and dim.
        
        /// Dim View
        dimView = DimView(in: self.view, forTrayView: menuBarView, withStyle: .top)
        menuBar.dimView = dimView
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(respondToDimViewTap(sender:))))

        menuBar.setUpView(trayOpenedHeight: 250, superview: menuBarView, trayClosedHeight: 100, placement: .top, style: .normal)

        let btn1 = TrayMenuButton(image: #imageLiteral(resourceName: "add"), description: "Add Task")
        let btn2 = TrayMenuButton(image: #imageLiteral(resourceName: "flame"), description: "Hot")
        let btn3 = TrayMenuButton(image: #imageLiteral(resourceName: "progress"), description: "Show Progress")
        let btn4 = TrayMenuButton(image: #imageLiteral(resourceName: "sort"), description: "Sort")
        let btn5 = TrayMenuButton(image: #imageLiteral(resourceName: "image"), description: "Images")
        let btn6 = TrayMenuButton(image: #imageLiteral(resourceName: "lens"), description: "Camera")
        let btn7 = TrayMenuButton(image: #imageLiteral(resourceName: "bitcoin"), description: "Wallet")
        let btn8 = TrayMenuButton(image: #imageLiteral(resourceName: "profile"), description: "Profile")
        let arr = [btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8]

        menuBar.addControls(controls: arr)
        
        /// Button targets
        
        btn1.addTarget(self, action: #selector(addTask(sender:)), for: .touchUpInside)
        //btn3.addTarget(self, action: #selector(handleShowProgressButton), for: .touchUpInside)
        // ...

//🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰
        

        /// Scheduled Timer
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(self.updateTimer(timer:)), userInfo: nil, repeats: true)
    
        
        /// Paths View
        
        rocketsStartPositions = priorityCircleOverallView.setRocketsStartPositions(relativeToView: view)
        
        let pathsView = PathsView()
        pathsView.backgroundColor = .clear
        pathsView.frame = view.frame
        let centerRocketPos = priorityCircleOverallView.centerRocketPositionRelative(to: self.view)
        let rocketStart = CGPoint(x: centerRocketPos.x, y: 100.0)
        
        
        for point in rocketsStartPositions {
            pathsView.addCustomPath(moveTo: rocketStart, endAt: point)
        }
        
        view.addSubview(pathsView)
        
    }

    
    
    
    deinit {
        print("💾 OverallViewController deinitialized...")
    }
    
    @objc func test(sender:UITapGestureRecognizer) {
       
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
        
        let testView = UIView(frame: .zero)
        
        testView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        let label = UILabel()
        label.text = "Coming soon..."
        label.font = UIFont(name: "Helvetica-Bold", size: 14)
        testView.addSubview(label)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.centerXAnchor.constraint(equalTo: testView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: testView.centerYAnchor).isActive = true
        
        
        menuBar.expand(withView: testView)
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool{
        return isStatusBarHidden
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
    
    override func viewDidAppear(_ animated: Bool) {
        handleShowProgress(value: 50.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       handleShowProgress(value: 0.0)
    }
    
    
    
}



// ⚡️ EXTENSIONS ⚡️



extension OverallViewController:PriorityCircleOverallDelegate {
    func tapped(on circle: CircleView) {
        let type = circle.taskType
        
        transition.setUp(circle: circle, duration: 0.1, centerPoint: priorityCircleOverallView.center)
        
        
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
    
    func stateChanged(state: TrayMenuState) {
        if state == .closed || state == .closing || state == .showing {
            isStatusBarHidden = false
        } else {
            isStatusBarHidden = true
        }
    }
}


