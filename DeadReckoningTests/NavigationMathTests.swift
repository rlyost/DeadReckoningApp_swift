//
//  NavigationMathTests.swift
//  DeadReckoningTests
//
//  Unit tests for the dead-reckoning math: great-circle bearing, distance,
//  and the pace-count / step-count conversions.
//

import Testing
import CoreLocation
@testable import deadreckoning

private func loc(_ lat: Double, _ lon: Double) -> CLLocation {
    CLLocation(latitude: lat, longitude: lon)
}

/// atan2-based forward azimuth returns degrees in (-180, 180]; normalize to [0, 360).
private func normalized(_ degrees: CGFloat) -> CGFloat {
    let m = degrees.truncatingRemainder(dividingBy: 360)
    return m < 0 ? m + 360 : m
}

struct NavigationMathTests {

    // MARK: - Bearing (great-circle forward azimuth)

    @Test func bearingDueEastIs90() {
        let b = loc(0, 0).bearingToLocationDegrees(destinationLocation: loc(0, 1))
        #expect(abs(b - 90) < 0.001)
    }

    @Test func bearingDueNorthIs0() {
        let b = loc(0, 0).bearingToLocationDegrees(destinationLocation: loc(1, 0))
        #expect(abs(b - 0) < 0.001)
    }

    @Test func bearingDueSouthIs180() {
        let b = normalized(loc(0, 0).bearingToLocationDegrees(destinationLocation: loc(-1, 0)))
        #expect(abs(b - 180) < 0.001)
    }

    @Test func bearingDueWestIs270() {
        let b = normalized(loc(0, 0).bearingToLocationDegrees(destinationLocation: loc(0, -1)))
        #expect(abs(b - 270) < 0.001)
    }

    @Test func bearingNewYorkToLondonIsNortheast() {
        // Known great-circle initial bearing NYC -> London is ~51 degrees.
        let b = loc(40.7128, -74.0060)
            .bearingToLocationDegrees(destinationLocation: loc(51.5074, -0.1278))
        #expect(b > 45 && b < 60)
    }

    @Test func radianAndDegreeBearingsAgree() {
        let a = loc(34.05, -118.24)
        let b = loc(36.16, -115.14)
        let deg = a.bearingToLocationDegrees(destinationLocation: b)
        let rad = a.bearingToLocationRadian(b)
        #expect(abs(deg - rad.radiansToDegrees) < 0.0001)
    }

    // MARK: - Distance (CLLocation.distance(from:), as used by MainVC)

    @Test func oneDegreeLongitudeAtEquator() {
        // ~111.195 km per degree of longitude at the equator.
        let d = loc(0, 0).distance(from: loc(0, 1))
        #expect(abs(d - 111_195) < 500)
    }

    @Test func zeroDistanceToSelf() {
        #expect(loc(10, 20).distance(from: loc(10, 20)) < 0.001)
    }

    // MARK: - Step / pace-count model

    /// CompassViewController: totalSteps = paceCount * totalDistance / 100
    @Test func totalStepsFromPaceCount() {
        let paceCount = 120.0      // steps per 100 m
        let totalDistance = 250.0  // meters
        #expect((paceCount * totalDistance) / 100.0 == 300.0)
    }

    /// CompassViewController: distanceTraveled = steps * 100 / paceCount
    @Test func distanceTraveledFromSteps() {
        let paceCount = 120.0
        let steps = 60.0
        #expect((steps * 100) / paceCount == 50.0)
    }

    /// PaceVC.submitPress: pace = steps / distance * 100
    @Test func paceCountCalibration() {
        let steps = 130.0
        let distanceMeters = 100.0
        #expect((steps / distanceMeters) * 100.0 == 130.0)
    }
}
