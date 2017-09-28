//
//  PathsView.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 25.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit

class PathsView: UIView {
    var paths:[UIBezierPath]?
    
    override func draw(_ rect: CGRect) {
        if paths != nil {
            for path in paths! {
                path.lineWidth = 2
                path.lineCapStyle = .round
                UIColor.magenta.setStroke()
                path.stroke()
            }
        }
    }
}
