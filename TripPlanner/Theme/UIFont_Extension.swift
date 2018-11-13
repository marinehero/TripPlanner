//
//  UIFont_Extension.swift
//  TripPlanner
//
//  Created by James Pereira on 2018-11-02.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import UIKit

extension UIFont {
    
    enum Theme {
        case mediumText
        
        var font: UIFont {
            switch self {
            case .mediumText:
                return UIFont.systemFont(ofSize: 18, weight: .medium)
            }
        }
    }
}
