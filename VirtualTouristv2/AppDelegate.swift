//
//  AppDelegate.swift
//  VirtualTouristv2
//
//  Created by Sean Goldsborough on 4/2/18.
//  Copyright © 2018 Sean Goldsborough. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VirtualTouristv2")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            print(storeDescription)
            
            if let error = error as NSError? {
                print("ERROR ON PERSISTENT CONTAINER LAZY VAR IN APP DELEGATE \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("DATA SAVED VIA saveContext METHOD IN APP DELEGATE")
            } catch {
                let saveContextError = error as NSError
                print("ERROR ON APP DELEGATE SAVE CONTEXT METHOD \(saveContextError.userInfo)")
            }
        }
    }
    
    func fetchPhotos(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil) throws -> [Photo]? {
        
        let context = persistentContainer.viewContext
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let photos = try context.fetch(fr) as? [Photo] else {
            return nil
        }
        return photos
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
}

