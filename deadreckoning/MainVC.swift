//
//  MainVC.swift
//  dead reckoning
//
//  Created by Rick Yost on 5/10/18.
//  Copyright © 2018-2026 Yost Group LLC. All rights reserved.
//

import UIKit
import CoreLocation

class MainVC: UIViewController {

    var latestLocation: CLLocation? = nil
    var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationDegrees(destinationLocation: self.yourLocation) ?? 0 }
    var distance: CGFloat { return CGFloat(latestLocation?.distance(from: self.yourLocation) ?? 0) }
    var yourLocation: CLLocation {
        get { return UserDefaults.standard.currentLocation }
        set { UserDefaults.standard.currentLocation = newValue }
    }
    var map: Bool = false
    var newDir: CGFloat?

    private var locationTask: Task<Void, Never>?
    
    @IBOutlet weak var paceCountField: UITextField!
    @IBOutlet weak var distanceField: UITextField!
    @IBOutlet weak var directionField: UITextField!

    @IBAction func calcPace(_ sender: UIButton) {
    }
    
    @IBAction func useMap(_ sender: UIButton) {
        performSegue(withIdentifier: "toMapSegue", sender: sender)
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        let pc = paceCountField.text ?? ""
        let dist = distanceField.text ?? ""
        let azimuth = directionField.text ?? ""

        if let paceValue = Double(pc), paceValue > 0,
           Double(dist) != nil, Double(azimuth) != nil {
            UserDefaults.standard.savedPaceCount = paceValue
            performSegue(withIdentifier: "toCompassSegue", sender: self)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Pace count, distance, and direction must all be valid numbers.", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Ok", style: .destructive)
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPaceCount" {
            let destination = segue.destination as! PaceVC
            destination.delegate = self
        } else if segue.identifier == "toAboutSegue" {
            let destination = segue.destination
            _ = destination.view
            if let label = destination.view.viewWithTag(42) as? UILabel,
               let currentText = label.text {
                let info = Bundle.main.infoDictionary
                let version = info?["CFBundleShortVersionString"] as? String ?? ""
                let build = info?["CFBundleVersion"] as? String ?? ""
                let versionString = "Version \(version) (\(build))"
                label.text = currentText.replacingOccurrences(
                    of: #"Version \S+"#,
                    with: versionString,
                    options: .regularExpression
                )
            }
        } else if segue.identifier == "toMapSegue" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! MapViewController
            controller.delegate = self
            controller.myLocation = latestLocation
        } else if segue.identifier == "toCompassSegue" {
            let compassVC = segue.destination as! CompassViewController
            compassVC.totalDistance = Double(distanceField.text ?? "") ?? 0
            compassVC.paceCount = Double(paceCountField.text ?? "") ?? 0
            compassVC.map = map
            let newDir = CGFloat(Double(directionField.text ?? "") ?? 0)
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

        if let savedPace = UserDefaults.standard.savedPaceCount {
            paceCountField.text = String(Int(savedPace))
        }

        startLocationUpdates()
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationTask?.cancel()
        locationTask = nil
    }

    func viewDidAppear() {
        map = false
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
        if let paceValue = Double(pace) {
            UserDefaults.standard.savedPaceCount = paceValue
        }
    }
}

// DELEGATE PROTOCOL
protocol CompassVCDelegate: AnyObject {
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
