//
//  Extensions.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 05.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

extension Int {
    static func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
}

extension UIColor {
    static func getOverlay(_ alpha:CGFloat) -> UIColor {
        return UIColor(white: 1, alpha: alpha)
    }
    
    static func defaultAppColors() -> [UIColor] {
        return [
            UIColor(red: 125/255, green: 167/255, blue: 217/255, alpha: 1.0),
            UIColor(red: 242/255, green: 109/255, blue: 125/255, alpha: 1.0),
            UIColor(red: 249/255, green: 173/255, blue: 129/255, alpha: 1.0)
        ]
    }
    
    static func makeLighterColor(of color:UIColor, by value:CGFloat) -> UIColor {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var alpha:CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        r += value
        g += value
        b += value
        
        if r > 1.0 {
            r = 1.0
        }
        
        if g > 1.0 {
            g = 1.0
        }
        
        if b > 1.0 {
            b = 1.0
        }
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }
}

extension CGFloat {
    func remap(from1:CGFloat, to1:CGFloat, from2:CGFloat, to2:CGFloat) -> CGFloat {
        return (self - from1) / (to1 - from1) * (to2 - from2) + from2
    }
}
