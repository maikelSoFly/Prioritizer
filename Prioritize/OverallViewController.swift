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
    fileprivate var dimView:DimView!
    private var timer:Timer!
    private var timerInterval:TimeInterval = 60
    private var isStatusBarHidden:Bool = false {
        didSet{
            UIView.animate(withDuration: 0.5) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    private var rocketsStartPositions = [CGPoint]()
    private var rocketLaunchPosition:CGPoint!
    private var pathsGenerator:PathsGenerator!
    private var nextButton:UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ok").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white.withAlphaComponent(0.68)
        button.addTarget(self, action: #selector(launchRocket), for: .touchUpInside)
        return button
    }()
    
    
    
    // 🔥 FUNCTIONS 🔥
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        
        
        //MARK: - Initializing Task Splitter.
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
        taskSplitter = TaskSplitter(title: "Main Task Splitter")
        priorityCircleOverallView.setUp(for: taskSplitter!)
        
        
        //MARK: - Tray menu.
        view.bringSubview(toFront: menuBarView)
    
//🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰
//   Process of adding Tray Menu with buttons and dim.
        
        //MARK: - Dim View
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
        
        //MARK: - Button targets
        
        btn1.addTarget(self, action: #selector(addTask(sender:)), for: .touchUpInside)
        //btn3.addTarget(self, action: #selector(handleShowProgressButton), for: .touchUpInside)
        // ...

//🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰🀰
        

        //MARK: - Scheduled Timer
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(self.updateTimer(timer:)), userInfo: nil, repeats: true)
    
        
        //MARK: - Rockets 🚀
        
        priorityCircleOverallView.setRocketsStartPositions()
        rocketsStartPositions = priorityCircleOverallView.getRocketsStartPositionsRelative(to: self.view)
        let centerRocketPos = priorityCircleOverallView.getCenterRocketStartPositionRelative(to: self.view)
        rocketLaunchPosition = CGPoint(x: centerRocketPos.x, y: 0)
        pathsGenerator = PathsGenerator(startPoint: rocketLaunchPosition, endPoints: rocketsStartPositions)
        
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
        if menuBar.state != .expanded {
            menuBar.use()
        }
    }
    
    @objc func addTask(sender:TrayMenuButton) {
        let addView = AddTaskView()
        addView.delegate = self
        
        menuBar.expand(withView: addView)
        
        //MARK: - 'Next' button
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nextButton)
        
        nextButton.widthAnchor.constraint(equalToConstant: 55).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let const = view.frame.height - (menuBarView.frame.origin.y + menuBarView.frame.height)
        nextButton.centerYAnchor.constraint(equalTo: menuBarView.bottomAnchor, constant: const/2).isActive = true
        
        nextButton.layer.masksToBounds = false
        nextButton.layer.shadowColor = UIColor.black.cgColor
        nextButton.layer.shadowRadius = 15
        nextButton.layer.shadowOpacity = 0.55
        nextButton.layer.cornerRadius = nextButton.frame.width/2
        
    }
    
    @objc private func launchRocket() {
        menuBar.closeFromEditing()
        let frame = CGRect(origin: rocketLaunchPosition, size: CGSize(width: 30, height: 30))
        
        let rocket = Rocket(frame: frame)
        rocket.delegate = self
        rocket.image = #imageLiteral(resourceName: "rock3t")
        view.insertSubview(rocket, belowSubview: menuBarView)
        let paths = pathsGenerator.pathsDictionary
        let randNum = Int(arc4random_uniform(UInt32(rocketsStartPositions.count)) + UInt32(0))
        let endPoint = NSValue(cgPoint: rocketsStartPositions[randNum])
        
        
        rocket.fly(from: rocketLaunchPosition, withPath: paths[endPoint]!, rotateTowardsBlackHole: priorityCircleOverallView.center)
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
        priorityCircleOverallView.showSectionCircles(bool: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        priorityCircleOverallView.showSectionCircles(bool: false)
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
    func menuDidEndEditing() {
        nextButton.removeFromSuperview()
    }
   
    func stateChanged(state: TrayMenuState) {
        if state == .closed || state == .closing || state == .showing || state == .expanded {
            isStatusBarHidden = false
        } else {
            isStatusBarHidden = true
        }
    }
}

extension OverallViewController:RocketDelegate {
    func rocketLanded(rocket:Rocket, on position:CGPoint) {
        let positionRelatedToPCOV = view.convert(position, to: priorityCircleOverallView)
        rocket.center = CGPoint(x: positionRelatedToPCOV.x, y: positionRelatedToPCOV.y)
        rocket.removeFromSuperview()
        priorityCircleOverallView.addRocket(rocket: rocket)
    }
}

extension OverallViewController:AddTaskViewDelegate {
    func launch() {
        launchRocket()
    }
}


