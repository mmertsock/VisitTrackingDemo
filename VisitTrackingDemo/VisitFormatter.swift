//
//  VisitFormatter.swift
//  VisitTrackingDemo
//
//  Created by Mike Mertsock on 11/15/17.
//  Copyright © 2017 Esker Apps. All rights reserved.
//

import Foundation

class VisitFormatter {
    
    let fullDateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    init() {
        fullDateFormatter.dateStyle = .short
        fullDateFormatter.timeStyle = .medium
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .medium
    }
    
    func fullString(_ date: Date) -> String {
        switch date {
        case .distantPast:
            return "distantPast"
        case .distantFuture:
            return "distantFuture"
        default:
            return fullDateFormatter.string(from: date)
        }
    }
    
    func timeString(_ date: Date) -> String {
        switch date {
        case .distantPast:
            return "distantPast"
        case .distantFuture:
            return "distantFuture"
        default:
            return timeFormatter.string(from: date)
        }
    }
}
