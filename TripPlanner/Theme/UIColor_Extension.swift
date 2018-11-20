//
//  UIColor_Extension.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/06.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation

import UIKit

extension UIColor {
    
    enum Theme {
        case defaultProfile
        
        var name: String {
            switch  self {
            case .defaultProfile:
                return "defaultProfile"
            }
        }
        
        var mainBackground: UIColor {
            switch self {
            case .defaultProfile:
                return UIColor.white
            }
        }

        var buttonBackground: UIColor {
            switch self {
            case .defaultProfile:
                return UIColor.blue
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .defaultProfile:
                return 5
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .defaultProfile:
                return 1
            }
        }
        
        var buttonBorder: UIColor {
            switch self {
            case .defaultProfile:
                return UIColor.cyan
            }
        }

        var buttonText: UIColor {
            switch self {
            case .defaultProfile:
                return UIColor.white
            }
        }
        

    }
    
}

extension CGFloat {
    
    enum Theme {
        case defaultProfile
        
        var name: String {
            switch  self {
            case .defaultProfile:
                return "defaultProfile"
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .defaultProfile:
                return 5
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .defaultProfile:
                return 1
            }
        }
        
    }
    
}
