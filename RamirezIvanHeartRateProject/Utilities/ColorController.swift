//
//  ColorController.swift
//  RamirezIvanHeartRateProject
//
//  Created by Ivan Ramirez on 4/13/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit

enum ColorController {
    case red
    case green
}

extension ColorController {
    var value: UIColor {
        get {
            switch self {
            case .green:
                return UIColor(red:0.55, green:0.75, blue:0.52, alpha:1.0)
            case .red:
                return UIColor(red:0.97, green:0.36, blue:0.25, alpha:1.0)
            }
        }
    }
}

