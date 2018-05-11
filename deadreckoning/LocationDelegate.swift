//
//  LocationDelegate.swift
//  dead reckoning
//
//  Created by Echelon Front on 11/05/18.
//  Copyright © 2018 Echelon Front. All rights reserved.
//

import Foundation
import CoreLocation

class LocationDelegate: NSObject, CLLocationManagerDelegate {
  var locationCallback: ((CLLocation) -> ())? = nil
  var headingCallback: ((CLLocationDirection) -> ())? = nil
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let currentLocation = locations.last else { return }
    locationCallback?(currentLocation)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    headingCallback?(newHeading.trueHeading)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("⚠️ Error while updating location " + error.localizedDescription)
  }
}
