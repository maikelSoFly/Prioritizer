//
//  TaskViewController.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 13/02/2018.
//  Copyright © 2018 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {
    var taskSplitter:TaskSplitter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rootVC = self.transitioningDelegate as! OverallViewController
        self.taskSplitter = rootVC.taskSplitter
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
