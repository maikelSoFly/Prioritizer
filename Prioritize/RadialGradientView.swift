//
//  RadialGradientView.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 22.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class RadialGradientView: UIView {
    var insideColor:UIColor!
    var outsideColor:UIColor!
    
    init(frame:CGRect, insideColor:UIColor, outsideColor:UIColor) {
        self.insideColor = insideColor
        self.outsideColor = outsideColor
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let colors = [insideColor.cgColor, outsideColor.cgColor] as CFArray
        //let locations:[CGFloat] = [0.0, 0.5, 0.5]
        let endRadius = sqrt(pow(frame.width/2, 2) + pow(frame.height/2, 2))
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil)
        let context = UIGraphicsGetCurrentContext()
        
        context?.drawRadialGradient(gradient!, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: endRadius, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
    }
}
