//
//  TrayMenuCollectionViewCell.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 15.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class TrayMenuCollectionViewCell: UICollectionViewCell {
    private weak var control:TrayMenuButton!
    
    private var label:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = .white
        view.font = UIFont(name: "Helvetica", size: 12)
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    func configure(object:TrayMenuButton) {
        self.control = object
        
        self.label.text = object.buttonDescription
        self.layer.masksToBounds = true
        layoutViews()
    }
    
    override func awakeFromNib() {
        
    }
    
    func layoutViews() {
        self.contentView.frame = self.bounds
        
        control.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(control)
        self.addSubview(label)
        
        control.tintColor = .white
        //control.showsTouchWhenHighlighted = true
    
        
        control.widthAnchor.constraint(equalToConstant: self.frame.width-14).isActive = true
        control.heightAnchor.constraint(equalToConstant: self.frame.height - 14).isActive = true
        let constraint = NSLayoutConstraint(item: control, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        constraint.isActive = true
        control.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        label.heightAnchor.constraint(equalToConstant: 14).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        control.layoutIfNeeded()
        control.layer.masksToBounds = true
        control.layer.cornerRadius = control.frame.size.width / 2
        control.backgroundColor = .white
        control.imageView?.contentMode = .scaleAspectFit
        control.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        control.tintColor = UIColor.black.withAlphaComponent(0.45)
    }
    
    
    
    
}
