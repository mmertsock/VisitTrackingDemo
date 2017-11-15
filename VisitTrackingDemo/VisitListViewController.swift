//
//  VisitListViewController.swift
//  VisitTrackingDemo
//
//  Created by Mike Mertsock on 11/15/17.
//  Copyright © 2017 Esker Apps. All rights reserved.
//

import UIKit
import CoreLocation

struct VisitGroup {
    let header: String
    let items: [VisitItem]
}

class VisitListViewController: UITableViewController {

    private var model = [VisitGroup]()
    private lazy var fmt = VisitFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .visitStoreDidUpdate, object: nil, queue: .main) {
            note in
            self.reloadModel()
        }
        
        reloadModel()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadModel), for: .valueChanged)
    }
    
    // MARK: - user interaction
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "visitSegue",
            let dest = segue.destination as? VisitItemViewController,
            let selected = tableView.indexPathForSelectedRow {
            dest.item = model[selected.section].items[selected.row]
        }
    }
    
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        let message = "Auth status: \(CLLocationManager.authorizationStatus().debugDescription)"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Start Monitoring", style: .default) {
            _ in
            VisitMonitor.shared.startMonitoringVisits()
        })
        alert.addAction(UIAlertAction(title: "Stop Monitoring", style: .default) {
            _ in
            VisitMonitor.shared.stopMonitoringVisits()
        })
        if !model.isEmpty {
            alert.addAction(UIAlertAction(title: "Share Event Log", style: .default) {
                _ in
                self.shareEventLog(from: sender)
            })
            alert.addAction(UIAlertAction(title: "Clear Event Log", style: .destructive) {
                _ in
                VisitStore.shared.reset()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.popoverPresentationController?.barButtonItem = sender
        present(alert, animated: true)
    }
    
    private func shareEventLog(from sender: UIBarButtonItem) {
        var items = model.flatMap { $0.items.map(self.activityItem) }
        guard !items.isEmpty else { return }
        items.insert("\(items.count) \(items.count == 1 ? "entry" : "entries"):", at: 0)
        let activityView = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityView.popoverPresentationController?.barButtonItem = sender
        present(activityView, animated: true)
    }
    
    private func activityItem(for item: VisitItem) -> String {
        var text = "\(item.isArrival ? "Arrival" : "Departure"), coordinate (\(item.lat), \(item.lon)) ± \(item.accuracy) m"
        if item.isArrival {
            text += ", at \(fmt.fullString(item.arrivalDate))"
        } else {
            text += ", \(fmt.fullString(item.arrivalDate)) -> \(fmt.fullString(item.departureDate))"
        }
        text += ", logged at \(fmt.fullString(item.timestamp))"
        return text
    }

    // MARK: - data source
    
    @objc func reloadModel() {
        refreshControl?.endRefreshing()
        model = groups(of: VisitStore.shared.allItems)
        tableView.reloadData()
    }
    
    private func groups(of items: [VisitItem]) -> [VisitGroup] {
        var lastHeader = ""
        var grouped: [VisitGroup] = []
        var nextGroupItems: [VisitItem] = []
        for item in items.reversed() {
            let thisHeader = header(for: item)
            if thisHeader == lastHeader {
                nextGroupItems.append(item)
            } else {
                if !nextGroupItems.isEmpty {
                    grouped.append(VisitGroup(header: lastHeader, items: nextGroupItems))
                }
                nextGroupItems = [item]
            }
            lastHeader = thisHeader
        }
        
        if !nextGroupItems.isEmpty {
            grouped.append(VisitGroup(header: lastHeader, items: nextGroupItems))
        }
        
        return grouped
    }
    
    private func header(for item: VisitItem) -> String {
        let components = Calendar.current.dateComponents(Set([.day, .month]), from: item.timestamp)
        return "\(components.month ?? 0)/\(components.day ?? 0)"
    }
    
    // MARK: - table view
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! VisitCell
        let item = model[indexPath.section].items[indexPath.row]
        let text = "Visit (\(item.coordinate.latitude), \(item.coordinate.longitude)), \(fmt.timeString(item.arrivalDate)) -> \(fmt.timeString(item.departureDate))"
        cell.label.text = text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model[section].header
    }
}

class VisitCell: UITableViewCell {
    @IBOutlet var label: UILabel!
}
