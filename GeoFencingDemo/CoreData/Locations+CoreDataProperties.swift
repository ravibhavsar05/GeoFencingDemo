
import Foundation
import CoreData
import CoreLocation

extension Locations {
    
    @nonobjc public class func nsfetchRequest() -> NSFetchRequest<Locations> {
        return NSFetchRequest<Locations>(entityName: "Locations")
    }
    
    @NSManaged public var latitude            : Double
    @NSManaged public var longitude           : Double
    @NSManaged public var radius              : Double
    @NSManaged public var identifier          : String
    @NSManaged public var note                : String
    @NSManaged public var isEntry             : Bool
    
    
    //------------------------------------------------------------------------------
    // MARK:- Fetch Record
    //------------------------------------------------------------------------------
    
    class func fetchGeotifications() -> [Locations]? {
        
        let fetchRequest = Locations.nsfetchRequest()
        
        do {
            let arrDecorations = try AppDelegate.shared.persistentContainer.viewContext.fetch(fetchRequest)
            return arrDecorations
            
        } catch {
            print("Locations - \(error.localizedDescription)")
            return nil
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK:- Save Record
    //------------------------------------------------------------------------------
    class func saveLocation(coordinaate:CLLocationCoordinate2D, note:String, isEntry:Bool, radius:Double, completionHandler: (_ isSuccess:Bool) -> Void){
        //.. Code process
        
        let managedContext = AppDelegate.shared.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "Locations", in: managedContext)
        
        let geotification = NSManagedObject(entity: userEntity!, insertInto: managedContext) as! Locations
        geotification.identifier = geotification.objectID.uriRepresentation().absoluteString
        geotification.isEntry = isEntry
        geotification.latitude = coordinaate.latitude
        geotification.longitude = coordinaate.longitude
        geotification.note = note
        geotification.radius = radius
        
        do {
            try managedContext.save()
            completionHandler(true)
        } catch {
            print("Failed saving")
            completionHandler(false)
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK:- Delete Record
    //------------------------------------------------------------------------------
    
    class func deleteRecord(forId: String) {
        
        let fetchRequest = Locations.nsfetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", forId)
        
        do {
            
            let arrLocations = try AppDelegate.shared.persistentContainer.viewContext.fetch(fetchRequest)
            if arrLocations.count > 0 {
                AppDelegate.shared.persistentContainer.viewContext.delete(arrLocations.first!)
                do {
                    try AppDelegate.shared.persistentContainer.viewContext.save()
                } catch {
                    print("Delete Failed")
                }
            }
            
        } catch {
            print("Locations Delete = \(error.localizedDescription)")
        }
    }
    
}
