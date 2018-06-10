//
//  MainVC.swift
//  dead reckoning
//
//  Created by Rick Yost on 5/10/18.
//  Copyright © 2018 Echelon Front. All rights reserved.
//

import UIKit
import CoreLocation

class MainVC: UIViewController {
    
    let locationDelegate = LocationDelegate()
    var latestLocation: CLLocation? = nil
    var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationDegrees(destinationLocation: self.yourLocation) ?? 0 }
    var distance: CGFloat { return CGFloat(latestLocation?.distance(from: self.yourLocation) ?? 0) }
    var yourLocation: CLLocation {
        get { return UserDefaults.standard.currentLocation }
        set { UserDefaults.standard.currentLocation = newValue }
    }
    var map: Bool = false
    var newDir: CGFloat?
    
    let locationManager: CLLocationManager = {
        $0.requestWhenInUseAuthorization()
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()
        $0.startUpdatingHeading()
        return $0
    }(CLLocationManager())
    
    @IBOutlet weak var paceCountField: UITextField!
    @IBOutlet weak var distanceField: UITextField!
    @IBOutlet weak var directionField: UITextField!

    @IBAction func calcPace(_ sender: UIButton) {
    }
    
    @IBAction func useMap(_ sender: UIButton) {
        performSegue(withIdentifier: "toMapSegue", sender: sender)
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        let pc = paceCountField.text!
        let dist = distanceField.text!
        let azimuth: String = directionField.text!
        
        if !pc.isEmpty && !dist.isEmpty && !azimuth.isEmpty {
            performSegue(withIdentifier: "toCompassSegue", sender: self)
        } else {
            let alertController = UIAlertController(title: "Error", message: "You must set all attributes first.", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Ok", style: .destructive)
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPaceCount" {
            let destination = segue.destination as! PaceVC
            destination.delegate = self
        } else if segue.identifier == "toMapSegue" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! MapViewController
            controller.delegate = self
            controller.myLocation = latestLocation
        } else if segue.identifier == "toCompassSegue" {
            let compassVC = segue.destination as! CompassViewController
            compassVC.totalDistance = Double(distanceField.text!)
            compassVC.paceCount = Double(paceCountField.text!)
            compassVC.map = map
            let newDir = CGFloat(Double(self.directionField.text!)!)
            print(newDir)
            compassVC.newDir = newDir
            compassVC.delegate = self
        }
    }
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainVC")
        locationManager.delegate = locationDelegate
        
        locationDelegate.locationCallback = { location in self.latestLocation = location }
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
    }
    func viewDidAppear() {
        map = false
    }
}


extension MainVC: MapViewControllerDelegate {
    func update(location: CLLocation) {
        map = true
        yourLocation = location
        print("Your Location \(yourLocation)")
        print("Your Location Bearing \(yourLocationBearing)")
        self.newDir = yourLocationBearing
        if(Int(yourLocationBearing) < 0) {
            directionField.text = String(Int(yourLocationBearing)+360)
        } else {
            directionField.text = String(Int(yourLocationBearing))
        }
        print("Distance: \(distance)")
        distanceField.text = String(Int(distance))
    }
}

extension MainVC: PaceItemLableDelegate {
    func itemPrint(by controller: PaceVC, with pace: String) {
        print(pace)
        paceCountField.text = pace
    }
}

// DELEGATE PROTOCOL
protocol CompassVCDelegate: class {
    func done()
}
//*******************

extension MainVC: CompassVCDelegate {
    func done() {
        dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var round: Bool {
        set {
            layer.cornerRadius = layer.bounds.height / 2
        }
        get {
            return layer.cornerRadius == layer.bounds.height / 2
        }
    }
}
