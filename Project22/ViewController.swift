//
//  ViewController.swift
//  Project22
//
//  Created by Grant Watson on 10/24/22.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var distanceReading: UILabel!
    @IBOutlet var beaconIdentifier: UILabel!
    @IBOutlet var circle: UIView!
    var locationManager: CLLocationManager?
    var isDetected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        circle.layer.zPosition = -1
        circle.layer.cornerRadius = circle.frame.width / 2
        circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        view.backgroundColor = .gray
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }

    func startScanning() {
        addBeacon(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5", major: 123, minor: 456, identifier: "Beacon1")
        addBeacon(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", major: 789, minor: 123, identifier: "Beacon2")
        addBeacon(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935", major: 456, minor: 789, identifier: "Beacon3")
    }
    
    func addBeacon(uuidString: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, identifier: String) {
        let uuid = UUID(uuidString: uuidString)!
        
        let beacon = CLBeaconRegion(uuid: uuid, major: major, minor: minor, identifier: identifier)
        locationManager?.startMonitoring(for: beacon)
        locationManager?.startRangingBeacons(satisfying: beacon.beaconIdentityConstraint)
    }
    
    func update(distance: CLProximity, identifier: String) {
        self.beaconIdentifier.text = identifier
        UIView.animate(withDuration: 1) {
            switch distance {
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
                self.circle.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
                self.circle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
                self.circle.transform = CGAffineTransform(scaleX: 1, y: 1)
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
                self.beaconIdentifier.text = "No beacon found."
                self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }
        }
        
        if distance != .unknown {
            if !isDetected {
                let ac = UIAlertController(title: "Beacon Found", message: "Your beacon has been located.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                isDetected = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity, identifier: beacon.uuid.uuidString)
        }
    }
}

