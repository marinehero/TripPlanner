//
//  UIImage_Extension.swift
//  TripPlanner
//
//  Created by James Pereira on 2018-11-02.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import UIKit

extension UIImage {
    
    enum Theme {
        case defaultProfile
        
        var name: String {
            switch  self {
            case .defaultProfile:
                return "defaultProfile"
            }
        }
            
        var image: UIImage {
            switch self {
            case .defaultProfile:
                return UIImage(named: self.name)!
            }
        }
    }
    
}
