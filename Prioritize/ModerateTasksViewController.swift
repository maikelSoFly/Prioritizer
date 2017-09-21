//
//  ObjectivesDetailsViewController.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 06.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class ModerateTasksViewController: UIViewController {
    @IBAction func handleDismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    deinit {
        print("💾 ModerateTasksViewController deinitialized...")
    }
    
    
    // ⚡️ FUNCTIONS
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func makeViewsVisibleAgainstBackground(color:UIColor) {
        label.textColor = color.contrastColor()
    }
    

  

}
