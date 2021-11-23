/*
 COPYRIGHT 1995-2021 ESRI

 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.

 This material is licensed for use under the Esri Master License
 Agreement (MLA), and is bound by the terms of that agreement.
 You may redistribute and use this code without modification,
 provided you adhere to the terms of the MLA and include this
 copyright notice.

 See use restrictions at http://www.esri.com/legal/pdfs/mla_e204_e300/english

 For additional information, contact:
 Environmental Systems Research Institute, Inc.
 Attn: Contracts and Legal Services Department
 380 New York Street
 Redlands, California, USA 92373

 email: contracts@esri.com
 */

import ArcGIS
import UIKit
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet weak var mapView: AGSMapView! {
        didSet {
            mapView.map = AGSMap(basemapStyle: .arcGISTopographic)
            mapView.locationDisplay.autoPanMode = .recenter
            mapView.graphicsOverlays.add(graphicsOverlay)
            mapView.touchDelegate = self
            
            // Make sure we allow background location updates.
            (mapView.locationDisplay.dataSource as? AGSCLLocationDataSource)?.locationManager.allowsBackgroundLocationUpdates = true
        }
    }
    
    private let graphicsOverlay = AGSGraphicsOverlay()
    private var observer: NSObjectProtocol?
    private var geotriggerMonitor: AGSGeotriggerMonitor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestNotificationAuthorization()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !mapView.locationDisplay.started {
            // Start location display with user's location.
            mapView.locationDisplay.start { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                } else {
                    // Start monitoring geotrigger notifications.
                    self?.startMonitoring()
                }
            }
        }
    }
    
    /// Makes the geotrigger monitor.
    /// - Returns: The geotrigger monitor.
    private func makeGeotriggerMonitor() -> AGSGeotriggerMonitor {
        let geotrigger = AGSFenceGeotrigger(
            feed: AGSLocationGeotriggerFeed(locationDataSource: mapView.locationDisplay.dataSource),
            ruleType: .enterOrExit,
            fenceParameters: AGSGraphicsOverlayFenceParameters(graphicsOverlay: graphicsOverlay, bufferDistance: 10),
            messageExpression: AGSArcadeExpression(expression: "$fencenotificationtype"),
            name: "Graphic Geotrigger"
        )
        return .init(geotrigger: geotrigger)
    }
    
    /// Starts monitoring geotrigger notifications.
    private func startMonitoring() {
        geotriggerMonitor = makeGeotriggerMonitor()
        geotriggerMonitor?.start()

        // Observe Geotrigger Notifications.
        observer = NotificationCenter.default.addObserver(
            forName: .AGSGeotriggerMonitorDidTrigger,
            object: geotriggerMonitor,
            queue: nil,
            using: { [weak self] notification in
                guard let geotriggerNotification =  notification.userInfo?[AGSGeotriggerNotificationInfoKey] as? AGSFenceGeotriggerNotificationInfo else { return }
                self?.scheduleBackgroundNotification(using: geotriggerNotification)
            }
        )
    }
    
    /// Show a simple alert to notify the user.
    /// - Parameters:
    ///   - title: The title on the alert.
    ///   - message: The message on the alert to describe any details.
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )
        
        present(alert, animated: true)
    }
    
    /// Requests notification authorization.
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] success, _ in
            guard let self = self else { return }
            // User denied notification authorization so show error alert.
            if !success {
                // Alerts must be presented on the main thread.
                DispatchQueue.main.async {
                    self.showAlert(
                        title: "Notifications cannot be shown",
                        message: "Turn on notifications in settings to see Geotrigger notifications"
                    )
                }
            }
        }
    }
    
    /// Schedules the notification to be pushed when the app is in the background.
    /// - Parameter notification: The notification to push.
    /// - Remark: The notification won't appear if the app is in the foreground.
    private func scheduleBackgroundNotification(using geotriggerNotification: AGSFenceGeotriggerNotificationInfo) {
        let content = UNMutableNotificationContent()
        content.title = "You have \(geotriggerNotification.message)"
        content.sound = .defaultCritical
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

extension ViewController: AGSGeoViewTouchDelegate {
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        let graphic = AGSGraphic(
            geometry: AGSGeometryEngine.bufferGeometry(mapPoint, byDistance: 50),
            symbol: AGSSimpleFillSymbol(style: .solid, color: .red, outline: nil),
            attributes: nil
        )
        graphicsOverlay.graphics.add(graphic)
    }
}
