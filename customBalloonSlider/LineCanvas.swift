//
//  LineView.swift
//  ballonSlider
//
//  Created by ABBAS on 10/28/19.
//  Copyright © 2019 ABBAS. All rights reserved.
//

import Foundation
import UIKit

class LineCanvas: UIView {
    
    private var color: UIColor!
    private var width: CGFloat!
    
    override func draw(_ rect: CGRect) {
        let aPath = UIBezierPath()
        
        aPath.move(to: CGPoint(x:0, y:0))
        aPath.lineWidth = width
        aPath.addLine(to: CGPoint(x:self.frame.size.width , y:0))
        aPath.close()
        color.set()
        aPath.stroke()
        aPath.fill()
    }
    
    func setStyle(color: UIColor, width: CGFloat) {
        self.color = color
        self.width = width
    }
    
}
