//
//  CoreDataTests.swift
//  iDispense
//
//  Created by Richard Henry on 15/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

import XCTest

class CoreDataTests: XCTestCase {

    var context: NSManagedObjectContext!

    override func setUp() {

        super.setUp()

        // Load the model from the bundle that contains this class.
        guard let model = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))]) else { XCTFail(); return }

        // Make a memory-backed store for testing porpoises.
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        do { try psc.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil) } catch { XCTFail();}

        // Create the context and add our persistent store coordinator to it.
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        if let context = context { context.persistentStoreCoordinator = psc } else { XCTFail() }
    }

    override func tearDown() {

        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func createEntity(_ name: String) -> AnyObject {

        return NSEntityDescription.insertNewObject(forEntityName: name, into: context!)
    }

    func countEntities(_ name: String) -> Int {

        //let err: NSErrorPointer? = nil
        //return context.count(for: NSFetchRequest(entityName: name), error: err)
        return 0
    }

    func createOrder(_ id: Int, interval: TimeInterval, comment: String) -> Order? {

        if let context = context, let order = NSEntityDescription.insertNewObject(forEntityName: "Order", into: context) as? Order {

            order.uuid = UIDevice.current.identifierForVendor?.uuidString ?? "NODEVICE" + "/\(id)"
            order.dateModified = Date(timeIntervalSince1970: interval)
            order.comments = comment

            // Non-optional
            order.date = Date()
            
            return order
        }

        return nil
    }

    func save() { try! context.save() }

    func notestDeduplicateByDate() {

        _ = createOrder(0, interval: 0, comment: "Delete")
        _ = createOrder(0, interval: 1, comment: "Survive")
        save()

        //context.performBlockAndWait { DeDuplicator.deDuplicateEntityWithName("Order", withUniqueAttributeName: "uuid", inContext: self.context, withCompareBlock: nil) }

        sleep(4)
        XCTAssertTrue(countEntities("Order") == 1)

        //DeDuplicator.deDuplicateEntityWithName("Order", withUniqueAttributeName: "status", inContext: context, withCompareBlock: { (Order o1, Order o2) in return o1 })
    }

    func notestPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
