//
//  AutoCompletable.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/03.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation
import UIKit

public protocol AutoCompletable {
    var autocompleteString: String { get }
}

extension String: AutoCompletable {
    public var autocompleteString: String {
        return self
    }
}
