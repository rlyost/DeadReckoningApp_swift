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
    // A negative headingAccuracy means the reported heading is invalid
    // (e.g. no location fix yet or magnetometer needs calibration).
    guard newHeading.headingAccuracy >= 0 else { return }
    // trueHeading is negative when the true-north reference is unavailable;
    // fall back to magneticHeading so the arrow still points somewhere sane.
    let heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    headingCallback?(heading)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("⚠️ Error while updating location " + error.localizedDescription)
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationCallback?(manager.authorizationStatus)
  }
}
