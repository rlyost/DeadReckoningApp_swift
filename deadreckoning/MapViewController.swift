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
  @IBOutlet weak var mapView: MKMapView!
  
  @IBAction func cancelTap(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func resetTap(_ sender: UIBarButtonItem) {
    delegate?.update(location: CLLocation(latitude: 90, longitude: 0))
    self.dismiss(animated: true, completion: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    mapView.showsUserLocation = true
    if #available(iOS 9, *) {
      mapView.showsScale = true
      mapView.showsCompass = true
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.didTap(_:)))
    mapView.addGestureRecognizer(gestureRecognizer)
  }

  @objc public func didTap(_ gestureRecognizer: UIGestureRecognizer) {
    let location = gestureRecognizer.location(in: mapView)
    let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
    print(coordinate.latitude, coordinate.longitude)
    
    delegate?.update(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    self.dismiss(animated: true, completion: nil)
  }
}


