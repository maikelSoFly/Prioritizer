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
    
    var trayMenuViewController:TrayMenuViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.masksToBounds = true
        
        trayMenuViewController.setUpView(trayOpenedHeight: 200, trayClosedHeight: 80, constraint: menuViewBottomConstraint, style: .bottom)
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
        trayMenuViewController.setUpContainer(insets: UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 50), itemsPerRow: 4)
        trayMenuViewController.addControls(controls: controls)
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
}
