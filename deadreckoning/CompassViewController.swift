//
//  CompassViewController.swift
//  dead reckoning
//
//  Created by Yost Group LLC on 11/05/18.
//  Copyright © 2018-2026 Yost Group LLC. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation

class CompassViewController: UIViewController {

    weak var delegate: CompassVCDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    
    //-----
    @IBOutlet weak var totalStepsLabel: UILabel!
    @IBOutlet weak var stepsLeftLabel: UILabel!
    @IBOutlet weak var stepsTakenLabel: UILabel!
    @IBOutlet weak var estimatedDistanceLeftLabel: UILabel!
    @IBOutlet weak var goalDistanceLabel: UILabel!
    @IBOutlet weak var walkStopButton: UIButton!
    var isWalking = false
    let pedometer = CMPedometer()
    var numberOfSteps: Double = 0
    var totalSteps: Double = 0
    var totalDistance: Double = 0
    var paceCount: Double = 0
    var map: Bool = false
    var newDir: CGFloat = 0
    //----
    
    let locationDelegate = LocationDelegate()

  // Navigation here is heading-driven (compass + fixed azimuth); GPS/liveUpdates
  // is intentionally not used on this screen to save battery.
  let locationManager: CLLocationManager = {
    $0.desiredAccuracy = kCLLocationAccuracyBest
    return $0
  }(CLLocationManager())
  
  private func orientationAdjustment() -> CGFloat {
    let isFaceDown: Bool = {
      switch UIDevice.current.orientation {
      case .faceDown: return true
      default: return false
      }
    }()
    
    let interfaceOrientation = view.window?.windowScene?.interfaceOrientation ?? .portrait
    let adjAngle: CGFloat = {
      switch interfaceOrientation {
      case .landscapeLeft:  return 90
      case .landscapeRight: return -90
      case .portrait, .unknown: return 0
      case .portraitUpsideDown: return isFaceDown ? 180 : -180
      @unknown default: return 0
      }
    }()
    return adjAngle
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    resetCourse()
    goalDistanceLabel.text = String(totalDistance) + " meters"
    totalSteps = (paceCount * totalDistance) / 100.0
    totalStepsLabel.text = String(Int(totalSteps)) + " steps"

    newDir = newDir.degreesToRadians
    
    // ---------
    
    locationDelegate.headingCallback = { [weak self] newHeading in
      guard let self else { return }

      func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
        let heading: CGFloat = {
          let originalHeading = self.newDir - newAngle.degreesToRadians
          switch UIDevice.current.orientation {
          case .faceDown: return -originalHeading
          default: return originalHeading
          }
        }()
        return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
      }

      UIView.animate(withDuration: 0.5) {
        let angle = computeNewAngle(with: CGFloat(newHeading))
        self.imageView.transform = CGAffineTransform(rotationAngle: angle)
      }
    }

    locationDelegate.authorizationCallback = { [weak self] status in
      guard let self else { return }
      switch status {
      case .authorizedWhenInUse, .authorizedAlways:
        self.locationManager.startUpdatingHeading()
      case .denied, .restricted:
        self.presentLocationDeniedAlert()
      case .notDetermined:
        self.locationManager.requestWhenInUseAuthorization()
      @unknown default:
        break
      }
    }

    locationManager.delegate = locationDelegate

    // VoiceOver: describe the guidance arrow.
    imageView.isAccessibilityElement = true
    imageView.accessibilityLabel = "Direction arrow. Rotate your body until it points straight up to follow your azimuth."
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    locationManager.stopUpdatingHeading()
    if isWalking {
      isWalking = false
      pedometer.stopUpdates()
    }
  }

  private func presentLocationDeniedAlert() {
    let alert = UIAlertController(
      title: "Compass Unavailable",
      message: "Location access is off, so the heading arrow can't update. Enable it in Settings.",
      preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
      }
    })
    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
    present(alert, animated: true)
  }
    // ---------------------

    func resetCourse() {
        enableWalkButton()
    }
    
    func enableWalkButton() {
        walkStopButton.isEnabled = true
        walkStopButton.backgroundColor = UIColor.green
        walkStopButton.setTitle("Walk", for: .normal)
    }
    
    func enableStopButton() {
        walkStopButton.isEnabled = true
        walkStopButton.backgroundColor = UIColor.red
        walkStopButton.setTitle("Stop", for: .normal)
    }
    
    @IBAction func walkStopButtonPress(_ sender: UIButton) {
        guard CMPedometer.isStepCountingAvailable() else {
            let alert = UIAlertController(
                title: "Step Counting Unavailable",
                message: "This device can't count steps, so distance can't be tracked.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        isWalking = !isWalking
        if (isWalking) {
            enableStopButton()
            pedometer.startUpdates(from: Date()) { data, error in
                guard let data else { return }
                let steps = Double(truncating: data.numberOfSteps)
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.numberOfSteps = steps
                    self.stepsTakenLabel.text = "\(Int(self.numberOfSteps)) steps"

                    let stepsLeft = self.totalSteps - self.numberOfSteps
                    let distanceTraveled = self.paceCount > 0 ? (self.numberOfSteps * 100) / self.paceCount : 0
                    let distanceLeft = self.totalDistance - distanceTraveled

                    self.stepsLeftLabel.text = "\(Int(stepsLeft)) steps"
                    self.estimatedDistanceLeftLabel.text =
                        String(format: "%02.02f meters", distanceLeft)

                    // Reached goal location?
                    if stepsLeft <= 0 && self.isWalking {
                        self.isWalking = false
                        self.pedometer.stopUpdates()
                        self.enableWalkButton()
                        let alertController = UIAlertController(title: "Congratulations!", message: "You've reached your goal!", preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
                            self?.delegate?.done()
                        }
                        alertController.addAction(action1)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            enableWalkButton()
            pedometer.stopUpdates()
        }
    }
}
