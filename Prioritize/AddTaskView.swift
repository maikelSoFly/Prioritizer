//
//  AddTaskView.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 23.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class AddTaskView: UIView {
    //MARK: Variables
    private var titleTextField:UITextField = {
        let label = UITextField()
        label.font = UIFont(name: "Helvetica", size: 12)
        label.placeholder = "Title"
        label.tintColor = .white
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        return label
    }()
    
    private var titleLabel:UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 12)
        label.textColor = .white
        label.text = "Task title"
        return label
    }()
    
    private var descriptionTextField:UITextView = {
        let label = UITextView()
        label.font = UIFont(name: "Helvetica", size: 12)
        label.tintColor = .white
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        return label
    }()
    
    private var descriptionLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 12)
        label.textColor = .white
        label.text = "Task info"
        return label
    }()
    
    
    
    

}
