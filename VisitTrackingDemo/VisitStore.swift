//
//  VisitStore.swift
//  VisitTrackingDemo
//
//  Created by Mike Mertsock on 11/15/17.
//  Copyright © 2017 Esker Apps. All rights reserved.
//

import Foundation
import CoreLocation

extension Notification.Name {
    static let visitStoreDidUpdate = Notification.Name("visitStoreDidUpdate")
}

struct VisitItem: Codable {
    
    let timestamp: Date
    let lat: CLLocationDegrees
    let lon: CLLocationDegrees
    let accuracy: CLLocationAccuracy
    let arrivalDate: Date
    let departureDate: Date
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var isArrival: Bool {
        return departureDate == .distantFuture
    }
    
    init(visit: CLVisit) {
        timestamp = Date()
        lat = visit.coordinate.latitude
        lon = visit.coordinate.longitude
        accuracy = visit.horizontalAccuracy
        arrivalDate = visit.arrivalDate
        departureDate = visit.departureDate
    }
}

class VisitStore {
    static let shared = VisitStore()
    
    let fakeData = false
    private var items = [VisitItem]()
    
    init() {
        let itemsAsJSON = UserDefaults.standard.stringArray(forKey: "visitStore-items") ?? []
        let decoder = JSONDecoder()
        items = itemsAsJSON.flatMap {
            json in
            return try? decoder.decode(VisitItem.self, from: json.data(using: .utf8)!)
        }
    }
    
    var allItems: [VisitItem] {
        assert(Thread.isMainThread)
        
        if fakeData {
            let json = """
{
        "timestamp": "2017-11-04T12:34:55Z",
"arrivalDate": "2017-11-04T12:34:55Z",
"departureDate": "2017-11-04T12:34:55Z",
"lat": 40.75,
"lon": -74,
"accuracy": 11
}
"""
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let item = try! decoder.decode(VisitItem.self, from: json.data(using: .utf8)!)
            return [item]
        }
        
        return items
    }
    
    func add(_ item: VisitItem) {
        assert(Thread.isMainThread)
        items.append(item)
        commit()
        notify()
    }
    
    func reset() {
        assert(Thread.isMainThread)
        items.removeAll()
        commit()
        notify()
    }
    
    private func commit() {
        let encoder = JSONEncoder()
        let jsonArray = items.flatMap {
            item in
            return String(data: (try! encoder.encode(item)), encoding: .utf8)
        }
        UserDefaults.standard.set(jsonArray, forKey: "visitStore-items")
    }
    
    private func notify() {
        NotificationCenter.default.post(name: .visitStoreDidUpdate, object: nil)
    }
}

