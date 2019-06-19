
import UIKit
import CoreData
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var window                        : UIWindow?
    let locationManager               = CLLocationManager()
    static let shared                 = UIApplication.shared.delegate as! AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current()
            .requestAuthorization(options: options) { success, error in
                if let error = error {
                    print("Error: \(error)")
                }
        }
        
        return true
    }
    
    //------------------------------------------------------------------------------
    // MARK: - Core Data stack
    //------------------------------------------------------------------------------
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "GeoFencingDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
extension AppDelegate {
    func handleEvent(for region: CLRegion!) {
        
        if UIApplication.shared.applicationState == .active {
            guard let message = fetchNote(from: region.identifier) else { return }
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
            
        } else {
            
            guard let body = fetchNote(from: region!.identifier) else { return }
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = body
            notificationContent.sound = UNNotificationSound.default
            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "location_change",
                                                content: notificationContent,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    func fetchNote(from identifier: String) -> String? {
        guard let geotifications = Locations.fetchGeotifications() else { return "" }
        guard let matched = geotifications.filter({
            $0.identifier == identifier
        }).first else { return nil }
        return matched.note
    }
}
//------------------------------------------------------------------------------
// MARK:- CLLocationManager Delegate
//------------------------------------------------------------------------------

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
    }
}

