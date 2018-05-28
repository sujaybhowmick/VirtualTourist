//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Sujay Bhowmick on 5/26/18.
//  Copyright © 2018 Sujay Bhowmick. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataStack {
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dbURL: URL
    internal let persistingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext
    
    static func shared() -> CoreDataStack {
        struct Singleton {
            static var shared = CoreDataStack(modelName: "Virtual-Tourist")!
        }
        return Singleton.shared
    }
    
    init?(modelName: String) {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil
        }
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        
        let fm = FileManager.default
        
        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the documents folder")
            return nil
        }
        
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        
        let options = [
            NSInferMappingModelAutomaticallyOption: true,
            NSMigratePersistentStoresAutomaticallyOption: true
        ]
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("unable to add store at \(dbURL)")
        }
    }
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
    
    func fetchPin(_ predicate: NSPredicate, entityName: String, sorting: NSSortDescriptor? = nil) throws -> Pin? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let pin = (try context.fetch(fr) as! [Pin]).first else {
            return nil
        }
        return pin
    }
    
    func fetchAllPins(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil) throws -> [Pin]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let pin = try context.fetch(fr) as? [Pin] else {
            return nil
        }
        return pin
    }
    
    func fetchPhotos(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil) throws -> [Photo]? {
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
}

internal extension CoreDataStack  {
    
    func dropAllData() throws {
       
        try coordinator.destroyPersistentStore(at: dbURL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}


extension CoreDataStack {
    
    func saveContext() throws {
        context.performAndWait() {
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    print("Error while saving main context: \(error)")
                }
                
                self.persistingContext.perform() {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        print("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            do {
                try saveContext()
                print("Autosaving")
            } catch {
                print("Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }
}
