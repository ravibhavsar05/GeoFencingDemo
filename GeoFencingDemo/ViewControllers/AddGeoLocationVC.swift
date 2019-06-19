import UIKit
import MapKit
import CoreData

class AddGeoLocationVC: UITableViewController {
    //------------------------------------------------------------------------------
    // MARK:- Variables & IBOutlets
    //------------------------------------------------------------------------------
    @IBOutlet var addButton                       : UIBarButtonItem!
    @IBOutlet var zoomButton                      : UIBarButtonItem!
    @IBOutlet weak var eventTypeSegmentedControl  : UISegmentedControl!
    @IBOutlet weak var radiusTextField            : UITextField!
    @IBOutlet weak var noteTextField              : UITextField!
    @IBOutlet weak var mapView                    : MKMapView!
    
    var geoLocations                              : [NSManagedObject] = []
    
    //------------------------------------------------------------------------------
    // MARK:- View Life Cycle methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [addButton, zoomButton]
        addButton.isEnabled = false
    }
    
    //------------------------------------------------------------------------------
    // MARK:- Actions
    //------------------------------------------------------------------------------
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        addButton.isEnabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onAdd(sender: AnyObject) {
        
        let coordinate = mapView.centerCoordinate
        let radius = Double(radiusTextField.text!) ?? 0
        let note = noteTextField.text!
        let eventType: Bool = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? true : false
        
        // Save location on local database.
        Locations.saveLocation(coordinaate: coordinate, note: note, isEntry: eventType, radius: radius, completionHandler: {  isSuccess in
            
            if isSuccess {
                dismiss(animated: true, completion: nil)
            } else {
                print("Something went wrong")
            }
        })
        
    }
    
    @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
}
