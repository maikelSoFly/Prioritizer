//
//  TrayMenuButtonView.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 17.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

enum TrayMenuTintStyle {
    case light, normal
}

class TrayMenuButton:UIButton {
    var buttonDescription: String
    private var _tintStyle:TrayMenuTintStyle = .normal
    var tintStyle:TrayMenuTintStyle {
        get {
            return _tintStyle
        }
        set {
            _tintStyle = newValue
            if newValue == .normal {
                tintColor = UIColor.black.withAlphaComponent(0.5)
            } else {
                backgroundColor = UIColor.white.withAlphaComponent(0.65)
                tintColor = UIColor.black.withAlphaComponent(0.2)
            }
        }
    }
    
    required init(image:UIImage, description:String) {
        self.buttonDescription = description
        super.init(frame: .zero)
        self.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        
        self.layer.masksToBounds = true
        self.backgroundColor = .white
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.backgroundColor = self.tintStyle == .normal ? .white : UIColor.white.withAlphaComponent(0.65)
                }, completion: nil)
            }
        }
    }
}
