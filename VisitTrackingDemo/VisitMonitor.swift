//
//  VisitMonitor.swift
//  VisitTrackingDemo
//
//  Created by Mike Mertsock on 11/15/17.
//  Copyright © 2017 Esker Apps. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

extension CLVisit {
    var isArrival: Bool {
        return departureDate == .distantFuture
    }
}

extension CLAuthorizationStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .denied: return "denied"
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        }
    }
}

class VisitMonitor: NSObject, CLLocationManagerDelegate {
    
    static let shared = VisitMonitor()
    
    private let locationManager: CLLocationManager
    private var shouldStartMonitoring = false
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }
    
    func startMonitoringVisits() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            NSLog("Starting visit monitoring")
            locationManager.startMonitoringVisits()
            shouldStartMonitoring = false
        } else {
            shouldStartMonitoring = true
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func stopMonitoringVisits() {
        NSLog("Stopping visit monitoring")
        locationManager.stopMonitoringVisits()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways && shouldStartMonitoring {
            NSLog("Starting visit monitoring")
            locationManager.startMonitoringVisits()
            shouldStartMonitoring = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let content = UNMutableNotificationContent()
        content.title = "Location Update"
        content.body = "Logged \(visit.isArrival ? "an Arrival" : "a Departure") visit: (\(visit.coordinate.latitude), \(visit.coordinate.longitude))"
        content.sound = UNNotificationSound.default()
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        VisitStore.shared.add(VisitItem(visit: visit))
    }
}
