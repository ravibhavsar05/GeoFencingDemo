
import Foundation
import CoreData
import MapKit

@objc(Locations)
public class Locations: NSManagedObject, MKAnnotation{
    
    // MKAnnotation default delegate variable.
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    // Set title foe MKAnnotation view.
    public var title: String? {
        return note
    }
}
