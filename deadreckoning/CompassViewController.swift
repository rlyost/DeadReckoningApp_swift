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
    var latestLocation: CLLocation? = nil
  var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.yourLocation) ?? 0 }
  var yourLocation: CLLocation {
    get { return UserDefaults.standard.currentLocation }
    set { UserDefaults.standard.currentLocation = newValue }
  }

  private var locationTask: Task<Void, Never>?

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
    print("CompassVC")
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
      case .notDetermined, .denied, .restricted:
        break
      @unknown default:
        break
      }
    }

    locationManager.delegate = locationDelegate
    startLocationUpdates()

    print("PaceCount: \(self.paceCount)")
    walkStopButtonPress(walkStopButton)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    locationTask?.cancel()
    locationTask = nil
    locationManager.stopUpdatingHeading()
  }

  private func startLocationUpdates() {
    locationTask?.cancel()
    locationTask = Task { @MainActor [weak self] in
      do {
        for try await update in CLLocationUpdate.liveUpdates() {
          if Task.isCancelled { return }
          guard let self else { return }
          if let location = update.location {
            self.latestLocation = location
          }
        }
      } catch {
        print("⚠️ Location stream error: \(error)")
      }
    }
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
        isWalking = !isWalking
        print(isWalking)
        if (isWalking) {
            enableStopButton()
            pedometer.startUpdates(from: Date()) { data, error in
                guard let data else { return }
                let steps = Double(truncating: data.numberOfSteps)
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    print("Update \(steps)")
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
                        print("Congrats!")
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
