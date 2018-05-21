//
//  CompassViewController.swift
//  dead reckoning
//
//  Created by Echelon Front on 11/05/18.
//  Copyright © 2018 Echelon Front. All rights reserved.
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
    var numberOfSteps:Double! = nil
    var totalSteps:Double! = nil
    var totalDistance:Double! = nil
    var paceCount:Double! = nil
    var map: Bool! = nil
    var newDir: CGFloat! = nil
    //----
    
    let locationDelegate = LocationDelegate()
    var latestLocation: CLLocation? = nil
  var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.yourLocation) ?? 0 }
  var yourLocation: CLLocation {
    get { return UserDefaults.standard.currentLocation }
    set { UserDefaults.standard.currentLocation = newValue }
  }
  
  let locationManager: CLLocationManager = {
    $0.requestWhenInUseAuthorization()
    $0.desiredAccuracy = kCLLocationAccuracyBest
    $0.startUpdatingLocation()
    $0.startUpdatingHeading()
    return $0
  }(CLLocationManager())
  
  private func orientationAdjustment() -> CGFloat {
    let isFaceDown: Bool = {
      switch UIDevice.current.orientation {
      case .faceDown: return true
      default: return false
      }
    }()
    
    let adjAngle: CGFloat = {
      switch UIApplication.shared.statusBarOrientation {
      case .landscapeLeft:  return 90
      case .landscapeRight: return -90
      case .portrait, .unknown: return 0
      case .portraitUpsideDown: return isFaceDown ? 180 : -180
      }
    }()
    return adjAngle
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("CompassVC")
    resetCourse()
    goalDistanceLabel.text = String(totalDistance!) + " meters"
    totalSteps = (paceCount * totalDistance) / 100.0
    totalStepsLabel.text = String(Int(totalSteps)) + " steps"
    
    print(map)
//    if(map){
//        newDir = yourLocationBearing
//        print("Top newDir: \(newDir!)")
//    } else {
        newDir = newDir.degreesToRadians
        print("Bottom newDir: \(newDir!)")
//    }
    
    // ---------
    
    locationManager.delegate = locationDelegate
    
    locationDelegate.locationCallback = { location in
      self.latestLocation = location
    }
    
    locationDelegate.headingCallback = { newHeading in
      
      func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
        let heading: CGFloat = {
          let originalHeading = self.newDir! - newAngle.degreesToRadians
          switch UIDevice.current.orientation {
          case .faceDown: return -originalHeading
          default: return originalHeading
          }
        }()
//        print(self.radiansToDegrees(Double(Int(heading))))
        return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
      }
      
      UIView.animate(withDuration: 0.5) {
        let angle = computeNewAngle(with: CGFloat(newHeading))
        self.imageView.transform = CGAffineTransform(rotationAngle: angle)
      }
    }
    print("PaceCount: \(self.paceCount!)")
    walkStopButtonPress(walkStopButton)
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
            pedometer.startUpdates(from:Date(), withHandler: { data, error in
                print("Update \(data?.numberOfSteps ?? 0)")
                self.numberOfSteps = Double(truncating: data!.numberOfSteps)
                
                DispatchQueue.main.async() {
                    self.stepsTakenLabel.text = "\(Int(self.numberOfSteps!)) steps"
                    
                    let stepsLeft = self.totalSteps - self.numberOfSteps
                    let distanceTraveled = (self.numberOfSteps * 100) / self.paceCount!
                    let distanceLeft = self.totalDistance - distanceTraveled
                    
                    self.stepsLeftLabel.text = "\(Int(stepsLeft)) steps"
                    self.estimatedDistanceLeftLabel.text =
                        String(format: "%02.02f meters", distanceLeft)
                    
                    // Reached goal?
                    if stepsLeft <= 0 {
                        print("Congrats!")
                        let alertController = UIAlertController(title: "Congratulations!", message: "You've reached your goal!'.", preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "Ok", style: .destructive)
                        alertController.addAction(action1)
                        self.present(alertController, animated: true, completion: self.delegate?.done)
                        self.isWalking = false
                        // reset?
                    }
                }
            })
        } else {
            enableWalkButton()
            pedometer.stopUpdates()
        }
    }
}
