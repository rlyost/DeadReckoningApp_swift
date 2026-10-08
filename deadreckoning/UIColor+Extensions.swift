//
//  UIColor+Extensions.swift
//  dead reckoning
//
//  Copyright © 2018-2026 Yost Group LLC. All rights reserved.
//

import UIKit

extension UIColor {
    /// Seamlessly tiling topographic-map pattern used behind every screen.
    /// Resolves per trait collection so it follows Light/Dark Mode.
    static let topoBackground = UIColor { traits in
        guard let tile = UIImage(named: "TopoBackground", in: nil, compatibleWith: traits) else {
            return .systemBackground
        }
        return UIColor(patternImage: tile)
    }
}
