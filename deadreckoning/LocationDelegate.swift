//
//  LocationDelegate.swift
//  dead reckoning
//
//  Created by Yost Group LLC on 11/05/18.
//  Copyright © 2018-2026 Yost Group LLC. All rights reserved.
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
