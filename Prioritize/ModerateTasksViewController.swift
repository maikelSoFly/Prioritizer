//
//  ObjectivesDetailsViewController.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 06.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class ModerateTasksViewController: TaskViewController {
    @IBAction func handleDismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var dismissButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Dismiss button
        dismissButton.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        dismissButton.tintColor = .white
        label.textColor = .white
        
        layoutViews()
    }
    
    deinit {
        print("💾 ModerateTasksViewController deinitialized...")
    }
    
    
    // ⚡️ FUNCTIONS
    
    private func layoutViews() {
        let label = UILabel()
        let rc = taskSplitter.moderates.count
        label.text = "\(rc) \(rc == 1 ? "rocket" : "rockets") trapped here..."
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let labelConstraints:[NSLayoutConstraint] = [
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 50.0)
        ]
        NSLayoutConstraint.activate(labelConstraints)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    

  

}
