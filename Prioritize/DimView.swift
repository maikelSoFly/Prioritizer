//
//  DimView.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 16.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class DimView: UIView {
    override var alpha: CGFloat {
        didSet {
            if alpha == 0.0 {
                self.isHidden = true
            } else {
                self.isHidden = false
            }
        }
    }

    init(in view: UIView, forTrayView tray:UIView, withStyle style:TrayMenuStyle) {
        let extendedFrame:CGRect
        
        if style == .top {
            extendedFrame = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.width, height: view.frame.height + tray.frame.height))
        } else {
            extendedFrame = CGRect(origin: CGPoint(x:0, y: -tray.frame.height), size: CGSize(width: view.frame.width, height: view.frame.height + tray.frame.height))
        }
        super.init(frame: extendedFrame)
        
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .black
        self.alpha = 0.0
        view.insertSubview(self, belowSubview: tray)
        setMask(with: tray.frame, in: self)
        setUpConstraints(in: view, forTrayView: tray, withStyle: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setMask(with hole:CGRect, in view:UIView) {
        let mutablePath = CGMutablePath()
        mutablePath.addRect(view.frame)
        mutablePath.addRoundedRect(in: hole, cornerWidth: 10, cornerHeight: 10)
        let mask = CAShapeLayer()
        
        // It is necessary when view has origin different than (0,0).
        // Mask's bounds and view's frame must match
        mask.bounds.origin = view.frame.origin
        
        mask.path = mutablePath
        mask.fillRule = kCAFillRuleEvenOdd
        view.layer.mask = mask
    }
    
    private func setUpConstraints(in view:UIView, forTrayView tray:UIView, withStyle style:TrayMenuStyle) {
        if style == .top {
            let dimConstraints:[NSLayoutConstraint] = [
                self.topAnchor.constraint(equalTo: tray.topAnchor),
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                self.widthAnchor.constraint(equalToConstant: self.frame.width),
                self.heightAnchor.constraint(equalToConstant: self.frame.height)
            ]
            NSLayoutConstraint.activate(dimConstraints)
        } else {
            
            let dimConstraints:[NSLayoutConstraint] = [
                self.bottomAnchor.constraint(equalTo: tray.bottomAnchor),
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                self.widthAnchor.constraint(equalToConstant: self.frame.width),
                self.heightAnchor.constraint(equalToConstant: self.frame.height)
            ]
            NSLayoutConstraint.activate(dimConstraints)
        }
    }

}
