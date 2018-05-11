//
//  MapViewControllerDelegate.swift
//  dead reckoning
//
//  Created by Rick Yost on 5/10/18.
//  Copyright © 2018 Kimchi Media. All rights reserved.
//

import Foundation
import CoreLocation

protocol MapViewControllerDelegate {
    func update(location: CLLocation)
}

