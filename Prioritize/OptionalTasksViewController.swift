//
//  TargetsDetailsViewController.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 06.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class OptionalTasksViewController: TaskViewController {
    @IBAction func handleDismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Dismiss button
        dismissButton.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        dismissButton.tintColor = .black
        label.textColor = .black

    
        layoutViews()
    }
    
    deinit {
        print("💾 OptionalTasksViewController deinitialized...")
    }
    
    
    //MARK: - FUNCTIONS
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func layoutViews() {
        let label = UILabel()
        let rc = taskSplitter.optionals.count
        label.text = "\(rc) \(rc == 1 ? "rocket" : "rockets") trapped here..."
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let labelConstraints:[NSLayoutConstraint] = [
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 50.0)
        ]
        NSLayoutConstraint.activate(labelConstraints)
    }
}

    
    


