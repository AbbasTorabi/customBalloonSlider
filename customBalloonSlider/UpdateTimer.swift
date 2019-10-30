//
//  UpdateTimer.swift
//  ballonSlider
//
//  Created by ABBAS on 10/30/19.
//  Copyright © 2019 ABBAS. All rights reserved.
//

import Foundation
import UIKit

protocol UpdateTimer {
    func onUpdate(position: CGFloat, rotation: CGFloat, side: Int8)
}
