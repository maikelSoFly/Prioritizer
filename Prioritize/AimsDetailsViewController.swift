//
//  AimsDetailsViewController.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 06.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class AimsDetailsViewController: UIViewController {
    @IBAction func handleDissmisButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var menuViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var trayMenuView: UIView!
    
    var trayMenuViewController:TrayMenuViewController!
    private var dimView:DimView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.masksToBounds = true
        
        trayMenuViewController.setUpView(trayOpenedHeight: 200, trayClosedHeight: 80, constraint: menuViewBottomConstraint, style: .bottom)
        
        let btn5 = TrayMenuButton(image: #imageLiteral(resourceName: "image"), description: "Images")
        let btn6 = TrayMenuButton(image: #imageLiteral(resourceName: "lens"), description: "Camera")
        let btn7 = TrayMenuButton(image: #imageLiteral(resourceName: "bitcoin"), description: "Wallet")
        let btn8 = TrayMenuButton(image: #imageLiteral(resourceName: "profile"), description: "Profile")
        
        trayMenuViewController.setUpContainer(insets: UIEdgeInsets(top: 30, left: 30, bottom: 10, right: 30), itemsPerRow: 4)
        trayMenuViewController.addControls(controls: [btn5, btn6, btn7, btn8])
        
        // Dim View
        dimView = DimView(in: self.view, forPopUpView: trayMenuView, withStyle: .bottom)
        trayMenuViewController.dimView = dimView
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(respondToDimViewTap(sender:))))
        
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

extension AimsDetailsViewController:TrayMenuDelegate {
    func updateLayout() {
        view.layoutIfNeeded()
    }
    
    func stateChanged(state: TrayMenuState) {
        
    }
    
    func verticalPosition(_ y: CGFloat) {
        
    }
}
