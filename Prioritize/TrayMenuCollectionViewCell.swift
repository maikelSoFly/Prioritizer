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
    private var labelHeight:CGFloat = 14
    private var tintStyle:TrayMenuTintStyle!
    
    private var label:UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = .white
        view.font = UIFont(name: "Helvetica", size: 12)
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    func configure(object:TrayMenuButton, tintStyle:TrayMenuTintStyle) {
        self.tintStyle = tintStyle
        self.control = object
        self.label.text = object.buttonDescription
        self.layer.masksToBounds = true
        layoutViews()
    }
    
    
    override func awakeFromNib() {
        
    }
    
    func layoutViews() {
        // This is important to make button circular
        self.contentView.frame = self.bounds
        
        control.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(control)
        self.addSubview(label)
    
        
        control.widthAnchor.constraint(equalToConstant: self.frame.height - (labelHeight+3)).isActive = true
        control.heightAnchor.constraint(equalToConstant: self.frame.height - (labelHeight+3)).isActive = true
        let constraint = NSLayoutConstraint(item: control, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        constraint.isActive = true
        control.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        label.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
        control.tintStyle = tintStyle
        control.layoutIfNeeded()
        control.layer.cornerRadius = control.frame.height / 2
        let inset = control.frame.height * 0.25
        control.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
}
