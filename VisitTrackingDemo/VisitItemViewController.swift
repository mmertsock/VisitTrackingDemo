//
//  VisitItemViewController.swift
//  VisitTrackingDemo
//
//  Created by Mike Mertsock on 11/15/17.
//  Copyright © 2017 Esker Apps. All rights reserved.
//

import UIKit
import MapKit

class VisitItemViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var arrivalLabel: UILabel!
    @IBOutlet var departureLabel: UILabel!
    @IBOutlet var coordinateLabel: UILabel!
    @IBOutlet var accuracyLabel: UILabel!
    
    var item: VisitItem?
    private lazy var fmt = VisitFormatter()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let item = item else { return }
        
        mapView.camera = MKMapCamera(lookingAtCenter: item.coordinate, fromEyeCoordinate: item.coordinate, eyeAltitude: 1250)
        let annotation = MKPointAnnotation()
        annotation.coordinate = item.coordinate
        mapView.addAnnotation(annotation)
        
        timestampLabel.text = "Recorded: \(fmt.fullString(item.timestamp))"
        arrivalLabel.text = "Arrival: \(fmt.timeString(item.arrivalDate))"
        departureLabel.text = "Departure: \(fmt.timeString(item.departureDate))"
        coordinateLabel.text = "Coordinate: (\(item.lat), \(item.lon))"
        accuracyLabel.text = "Accuracy: ±\(item.accuracy) m"
    }
}
