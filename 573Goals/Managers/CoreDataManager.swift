//
//  CoreDataManager.swift
//  573Goals
//
//  Created by Kinney Kare on 1/3/24.
//

import UIKit
import CoreData

class CoreDataManager {
    
    private let modelName: String
    private let persistentContainer: NSPersistentCloudKitContainer
    
    // MARK: - Initialization
    
    init(modelName: String, persistentContainer: NSPersistentCloudKitContainer) {
        self.modelName = modelName
        self.persistentContainer = persistentContainer
    }

    // MARK: - Core Data Operations
    
    func saveContext() {
        guard persistentContainer.viewContext.hasChanges else { return }
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    // Expose viewContext for direct access
    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Fetch Request
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate? = nil) -> Result<[T], Error>  {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        do {
            let result = try persistentContainer.viewContext.fetch(fetchRequest)
            return .success(result)
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    // MARK: - Delete
    func delete(_ object: NSManagedObject) {
        persistentContainer.viewContext.delete(object)
        saveContext()
    }
}
