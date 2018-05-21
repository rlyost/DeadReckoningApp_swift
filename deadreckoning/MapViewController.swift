//
//  MapViewController.swift
//  dead reckoning
//
//  Created by Echelon Front on 11/05/18.
//  Copyright © 2018 Echelon Front. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
  var delegate: MapViewControllerDelegate!
  var myLocation: CLLocation?
  let regionRadius: CLLocationDistance = 1000
  @IBOutlet weak var mapView: MKMapView!
  
  @IBAction func cancelTap(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func resetTap(_ sender: UIBarButtonItem) {
    delegate?.update(location: CLLocation(latitude: 90, longitude: 0))
    self.dismiss(animated: true, completion: nil)
  }
  
    //Set up Mapview
  override func viewWillAppear(_ animated: Bool) {
    mapView.showsUserLocation = true
    if #available(iOS 9, *) {
      mapView.showsScale = true
      mapView.showsCompass = true
    }
    centerMapOnLocation(location: myLocation!)
  }
    
  //Center and Zoom intial view your location
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
    //Add Tap Gesture Recognizer to view
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.didTap(_:)))
    mapView.addGestureRecognizer(gestureRecognizer)
  }

    //Listen for screen tap and pass location to MainVC
  @objc public func didTap(_ gestureRecognizer: UIGestureRecognizer) {
    let location = gestureRecognizer.location(in: mapView)
    let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
    print(coordinate.latitude, coordinate.longitude)
    
    delegate?.update(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    self.dismiss(animated: true, completion: nil)
  }
}


