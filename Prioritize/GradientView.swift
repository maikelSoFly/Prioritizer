//
//  GradientView.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 14.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    private var colors:[CGColor] = [CGColor]()
    private var locations:[CGFloat] = [CGFloat]()
    
    var gradientLayer:CAGradientLayer!
    
    @IBInspectable var color1:UIColor = #colorLiteral(red: 0.2042817771, green: 0.6683536768, blue: 0.7161468863, alpha: 1)
    @IBInspectable var color2:UIColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
    @IBInspectable var location1:CGFloat = -0.5
    @IBInspectable var location2:CGFloat = 1.5
    
    
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        colors.append(contentsOf: [color1.cgColor, color2.cgColor])
        locations.append(contentsOf: [location1, location2])
        
        gradientLayer = self.layer as? CAGradientLayer
        
        gradientLayer.colors = colors
        gradientLayer.locations = locations as [NSNumber]
        gradientLayer.bounds = self.bounds
    }
}

