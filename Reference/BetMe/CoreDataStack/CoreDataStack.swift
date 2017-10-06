//
//  CoreDataStack.swift
//  BetMe
//
//  Created by Rich Henry on 04/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataStack {

    public private(set) lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: self.modelName)

        // Set the container description if one's been specified.
        if let description = self.storeDescription { container.persistentStoreDescriptions = description }

        container.loadPersistentStores() { (storeDescription, error) in

            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */

            reportError(error: error)
        }
        
        return container
    }()

    public var storeDescription: [NSPersistentStoreDescription]? = nil

    private var modelName: String

    // MARK: Lifecycle

    public init(modelName: String = "Model") {
        
        self.modelName = modelName
    }

    deinit {

        print("CoreDataStack deinit")
    }

    // MARK: Database Commits

    public func save() {

        let context = persistentContainer.viewContext

        if context.hasChanges {

            do { try context.save() }

            catch { reportError(error: error) }
        }
    }

    // MARK: Batch operations

    public func batchDeleteObjects(ofType eName: String) {

        persistentContainer.performBackgroundTask { context in

            // Create a fetch request that will just fetch the Object IDs
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: eName)
            fetchRequest.includesPropertyValues = false

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            // Set what we want to return in the result before the execution.
            // https://developer.apple.com/library/content/featuredarticles/CoreData_Batch_Guide/BatchDeletes/BatchDeletes.html
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult

                if let objectIDArray = result?.result as? [NSManagedObjectID] {

                    let changes = [NSDeletedObjectsKey : objectIDArray]

                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.persistentContainer.viewContext])
                }
            }

            catch { reportError(error: error) }
        }
    }
}

// MARK: Error Handling

internal func reportError(error: Error?) {

    // TODO: Replace this implementation with code to handle the error appropriately.
    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

    if let nserror = error as NSError? { fatalError("Unresolved error in CoreDataStack \(nserror), \(nserror.userInfo)") }
}
