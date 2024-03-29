

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        guard let person = RDPerson(filename: "A") else {
            fatalError("A.ics is missing")
        }
        
        let entryVC = RDCalendarVC(person: person)
        let navigationController = UINavigationController(rootViewController: entryVC)
        window?.rootViewController = navigationController
        
        return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {  }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }
}

