//
//  UserDefaults+Extensions.swift
//  dead reckoning
//
//  Created by Yost Group LLC on 11/05/18.
//  Copyright © 2018-2026 Yost Group LLC. All rights reserved.
//

import Foundation
import CoreLocation

extension UserDefaults {
  var currentLocation: CLLocation? {
    get {
      guard let latitude, let longitude else { return nil } // no destination selected yet
      return CLLocation(latitude: latitude, longitude: longitude)
    }
    set {
      latitude = newValue?.coordinate.latitude
      longitude = newValue?.coordinate.longitude
    }
  }

  var savedPaceCount: Double? {
    get {
      if object(forKey: #function) != nil {
        return double(forKey: #function)
      }
      return nil
    }
    set { set(newValue, forKey: #function) }
  }
  
  private var latitude: Double? {
    get {
      if let _ = object(forKey: #function) {
        return double(forKey: #function)
      }
      return nil
    }
    set { set(newValue, forKey: #function) }
  }
  
  private var longitude: Double? {
    get {
      if let _ = object(forKey: #function) {
        return double(forKey: #function)
      }
      return nil
    }
    set { set(newValue, forKey: #function) }
  }
}
