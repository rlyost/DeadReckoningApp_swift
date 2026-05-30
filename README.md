# Dead Reckoning

U.S. Army FM 3-25.26 Section 12-5. DEAD RECKONING NAVIGATION

Dead reckoning is moving a set distance along a set line. Generally, it involves moving so many meters along a set line, usually an azimuth in degrees.

The app has a pace count calculator.

Provides click-on-the-map functionality for distance and direction, then navigates you to the point using step / distance calculations and provides an arrow for direction.

## Requirements

- iOS 17.0 or later
- Xcode with Swift 5

## Frameworks

- UIKit
- MapKit
- CoreLocation (uses the iOS 17 `CLLocationUpdate.liveUpdates()` async API)
- CoreMotion (CMPedometer)
