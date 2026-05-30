//
//  LocationDelegate.swift
//  dead reckoning
//
//  Created by Echelon Front on 11/05/18.
//  Copyright © 2018 Echelon Front. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationDelegate: NSObject, CLLocationManagerDelegate {
  var headingCallback: ((CLLocationDirection) -> ())? = nil
  var authorizationCallback: ((CLAuthorizationStatus) -> ())? = nil

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    headingCallback?(newHeading.trueHeading)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("⚠️ Error while updating location " + error.localizedDescription)
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationCallback?(manager.authorizationStatus)
  }
}
