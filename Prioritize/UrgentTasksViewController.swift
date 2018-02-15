//
//  AimsDetailsViewController.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 06.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class UrgentTasksViewController: TaskViewController {
    @IBAction func handleDissmisButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var trayMenuView: UIView!
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    weak var trayMenuViewController:TrayMenuViewController!
    private var dimView:DimView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.masksToBounds = true
        
        /// Dismiss Button
        dismissButton.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        dismissButton.tintColor = .white
        label.textColor = .white
        
        
        // Dim View
        
        dimView = DimView(in: self.view, forTrayView: trayMenuView, withStyle: .bottom)
        trayMenuViewController.dimView = dimView
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(respondToDimViewTap(sender:))))
        
        
        trayMenuViewController.setUpView(trayOpenedHeight: 200, superview: trayMenuView, trayClosedHeight: 80, placement: .bottom, style: .discreet)
        
        let btn5 = TrayMenuButton(image: #imageLiteral(resourceName: "check"), description: "Check")
        let btn6 = TrayMenuButton(image: #imageLiteral(resourceName: "addReminder"), description: "Add Reminder")
        let btn7 = TrayMenuButton(image: #imageLiteral(resourceName: "removeFolder"), description: "Remove All")
        let btn8 = TrayMenuButton(image: #imageLiteral(resourceName: "sort"), description: "Sort")
        
        trayMenuViewController.setUpContainer(insets: UIEdgeInsets(top: 20, left: 30, bottom: 25, right: 30), itemsPerRow: 4)
        trayMenuViewController.addControls(controls: [btn5, btn6, btn7, btn8])
        
        layoutViews()
    }
    
    
    // ⚡️ FUNCTIONS
    
    private func layoutViews() {
        let label = UILabel()
        let rc = taskSplitter.urgents.count
        label.text = "\(rc) \(rc == 1 ? "rocket" : "rockets") trapped here..."
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(label, belowSubview: trayMenuView)
        
        let labelConstraints:[NSLayoutConstraint] = [
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 50.0)
        ]
        NSLayoutConstraint.activate(labelConstraints)
    }
    
    deinit {
        print("💾 UrgentTasksViewController deinitialized...")
    }
    
    
    @objc func respondToDimViewTap(sender:UITapGestureRecognizer) {
        trayMenuViewController.use()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TrayMenuViewController {
            trayMenuViewController = vc
            trayMenuViewController.delegate = self
            return
        }
    }

}

extension UrgentTasksViewController:TrayMenuDelegate {
    func updateLayout() {
        view.layoutIfNeeded()
    }
}
