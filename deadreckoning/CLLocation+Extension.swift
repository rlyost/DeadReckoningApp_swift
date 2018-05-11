//
//  CLLocation+Extension.swift
//  dead reckoning
//
//  Created by Echelon Front on 11/05/18.
//  Copyright © 2018 Echelon Front. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

public extension CLLocation {
  func bearingToLocationRadian(_ destinationLocation: CLLocation) -> CGFloat {
    
    let lat1 = self.coordinate.latitude.degreesToRadians
    let lon1 = self.coordinate.longitude.degreesToRadians
    
    let lat2 = destinationLocation.coordinate.latitude.degreesToRadians
    let lon2 = destinationLocation.coordinate.longitude.degreesToRadians
    
    let dLon = lon2 - lon1
//    print("Distance: \(Int(self.distance(Double(lat1),Double(lon1),Double(lat2),Double(lon2))))")
    
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radiansBearing = atan2(y, x)
    return CGFloat(radiansBearing)
  }
    
    // RICKS FUNCTION
    func distance(_ destinationLocation: CLLocation) -> Double {
        let lat1 = self.coordinate.latitude.degreesToRadians
        let lon1 = self.coordinate.longitude.degreesToRadians
        
        let lat2 = destinationLocation.coordinate.latitude.degreesToRadians
        let lon2 = destinationLocation.coordinate.longitude.degreesToRadians
        
        let p:Double = .pi;    // Math.PI / 180
        let a = 0.5 - cos((lat2 - lat1) * p)/2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p))/2;
        let dis = Double((12742 * sin(a.squareRoot()))*1000); // 2 * R; R = 6371 km
        return dis
    }
  
  func bearingToLocationDegrees(destinationLocation: CLLocation) -> CGFloat {
    return bearingToLocationRadian(destinationLocation).radiansToDegrees
  }
}

extension CGFloat {
  var degreesToRadians: CGFloat { return self * .pi / 180 }
  var radiansToDegrees: CGFloat { return self * 180 / .pi }
}

private extension Double {
  var degreesToRadians: Double { return Double(CGFloat(self).degreesToRadians) }
  var radiansToDegrees: Double { return Double(CGFloat(self).radiansToDegrees) }
}
