
import UIKit
import MapKit
import CoreLocation
import CoreData

class GeoMapVC: UIViewController {
    //------------------------------------------------------------------------------
    // MARK:- Variables & IBOutlets
    //------------------------------------------------------------------------------
    var currentLocation : CLLocation? {
        didSet{
            evaluateClosestRegions()
        }
    }
    
    @IBOutlet weak var mapView          : MKMapView!
    
    var geoLocations                    : [Locations] = []
    var locationManager                 = CLLocationManager()
    var allRegions                      : [CLRegion:String] = [:] // Fill all your regions
    var allIdentifier                   : [String] = []
    
    //------------------------------------------------------------------------------
    // MARK:- View Life Cycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadAllGeotifications()
    }
    
    //------------------------------------------------------------------------------
    // MARK:- Actions
    //------------------------------------------------------------------------------
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
    
    //------------------------------------------------------------------------------
    // MARK:- Loading and saving functions
    //------------------------------------------------------------------------------
    func loadAllGeotifications() {
        geoLocations.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        allRegions.removeAll()
        if Locations.fetchGeotifications() != nil {
            for clregion in Locations.fetchGeotifications()!
            {
                let abc : CLRegion = region(with: clregion)
                allRegions[abc] = clregion.identifier
                allIdentifier.append(clregion.identifier)
            }
        }
        if currentLocation != nil {
            evaluateClosestRegions()
        }
    }
    
    // Calculate closest first 20 locations
    func evaluateClosestRegions() {
        
        var allDistance : [Double] = []
        
        //Calulate distance of each region's center to currentLocation
        for region in allRegions{
            let circularRegion = region.key as! CLCircularRegion
            let distance = currentLocation!.distance(from: CLLocation(latitude: circularRegion.center.latitude, longitude: circularRegion.center.longitude))
            allDistance.append(distance)
        }
        
        // a Array of Tuples
        let distanceOfEachRegionToCurrentLocation = zip(allRegions, allDistance)
        
        //sort and get 20 closest
        let twentyNearbyRegions = distanceOfEachRegionToCurrentLocation
            .sorted{ tuple1, tuple2 in return tuple1.1 < tuple2.1 }
            .prefix(20)
        
        // Remove all regions you were tracking before
        for region in locationManager.monitoredRegions{
            locationManager.stopMonitoring(for: region)
        }
        
        twentyNearbyRegions.forEach{
            locationManager.startMonitoring(for: $0.0.key)
        }
        
        geoLocations.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        for region in twentyNearbyRegions {
            for geoRegion in Locations.fetchGeotifications()! {
                if region.0.value == geoRegion.identifier {
                    add(geoRegion)
                }
            }
        }
        updateGeotificationsCount()
    }
    
    // Append Location
    func add(_ location: Locations) {
        geoLocations.append(location)
        mapView.addAnnotation(location as MKAnnotation)
        addRadiusOverlay(forGeotification: location)
    }
    
    // Remove Location
    func remove(_ location: Locations) {
        guard let index = geoLocations.firstIndex(of: location) else { return }
        geoLocations.remove(at: index)
        mapView.removeAnnotation(location as MKAnnotation)
        removeRadiusOverlay(forGeotification: location)
        updateGeotificationsCount()
    }
    
    // Update Count in navBar
    func updateGeotificationsCount() {
        title = "Geotifications: \(geoLocations.count)"
    }
    
    // Add overlay
    func addRadiusOverlay(forGeotification geotification: Locations) {
        mapView?.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    // Remove overlay
    func removeRadiusOverlay(forGeotification geotification: Locations) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                mapView?.removeOverlay(circleOverlay)
                break
            }
        }
    }
    
    func region(with location: Locations) -> CLCircularRegion {
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), radius: location.radius, identifier: location.identifier)
        region.notifyOnEntry = (location.isEntry)
        region.notifyOnExit = !(location.isEntry)
        return region
    }
}
//------------------------------------------------------------------------------
// MARK:- CLLocationManager Delegate
//------------------------------------------------------------------------------
extension GeoMapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        geoLocations.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        currentLocation = manager.location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .authorizedAlways
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
}
//------------------------------------------------------------------------------
// MARK:- MapView Delegate
//------------------------------------------------------------------------------
extension GeoMapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //Add View for annotation
        let identifier = "myGeotification"
        if annotation is Locations {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "DeleteGeotification")!, for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Add Circular Overlay
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 0.8
            circleRenderer.strokeColor = .green
            circleRenderer.fillColor = UIColor.green.withAlphaComponent(0.3)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete
        let geotification = view.annotation as! Locations
        remove(geotification)
        Locations.deleteRecord(forId: geotification.identifier)
    }
}
