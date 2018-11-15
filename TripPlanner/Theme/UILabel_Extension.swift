//
//  UILabel_Extension.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/14.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    fileprivate convenience init(text: String, style: UIFont.TextStyle) {
        self.init()
        font = UIFont.preferredFont(forTextStyle: style)
        self.text = text
        textColor = UIColor(white: 0.1, alpha: 1)
        backgroundColor = .clear
    }
    
}

typealias Constraint = (UIView, UIView) -> NSLayoutConstraint

func equal<L, Axis>(_ to: KeyPath<UIView, L>, constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    return equal(to, to, constant: constant)
}

func equal<L, Axis>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    return { view1, view2 in
        view1[keyPath: from].constraint(equalTo: view2[keyPath: to], constant: constant)
    }
}

func equal<L>(_ keyPath: KeyPath<UIView, L>, constant: CGFloat) -> Constraint where L: NSLayoutDimension {
    return { view1, _ in
        view1[keyPath: keyPath].constraint(equalToConstant: constant)
    }
}

extension UIView {
    func addSubview(_ other: UIView, constraints: [Constraint]) {
        other.translatesAutoresizingMaskIntoConstraints = false
        addSubview(other)
        addConstraints(constraints.map { $0(other, self) })
    }
}

extension Array where Element == Constraint {
    static func allEqual(margin: CGFloat = 0) -> [Constraint] {
        return [
            equal(\.topAnchor, constant: margin), equal(\.bottomAnchor, constant: margin),
            equal(\.leftAnchor, constant: margin), equal(\.rightAnchor, constant: margin)
        ]
    }
}

func buildPopup(icon: String = "ⓘ", headline headlineText: String, body bodyText: String) -> UIView {
    let container = UIView()
    container.layer.cornerRadius = 10
    container.layer.masksToBounds = true
    
    let header = UILabel(text: icon, style: UIFont.TextStyle.largeTitle)
    let headline = UILabel(text: headlineText, style: .body)
    let body = UILabel(text: bodyText, style: .caption1)
    body.numberOfLines = 0
    
    let effect = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    container.addSubview(effect, constraints: .allEqual())
    
    let stack = UIStackView(arrangedSubviews: [header, headline, body])
    stack.axis = .vertical
    stack.alignment = .center
    container.addSubview(stack, constraints: .allEqual(margin: 0))
    
    container.frame = CGRect(x: 0, y: 0, width: 360, height: 300)

    return container
}
