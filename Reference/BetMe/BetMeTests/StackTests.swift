//
//  StackTests.swift
//  StackTests
//
//  Created by Rich Henry on 03/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import XCTest
import CoreData
import CoreDataStack

@testable import BetMe

class StackTests: XCTestCase {

    var coreDataStack: CoreDataStack!

    override func setUp() {

        super.setUp()

        coreDataStack = CoreDataStack(modelName: "Model")

        // Make an in-memory store
        let desc = NSPersistentStoreDescription()

        desc.type = NSInMemoryStoreType
        desc.configuration = "Default"

        coreDataStack.storeDescription = [desc]
    }

    override func tearDown() {

        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {

        XCTAssertNotNil(coreDataStack)
        XCTAssertNotNil(coreDataStack.persistentContainer)
    }

    func testInsertInViewContext() {

        let context = coreDataStack.persistentContainer.viewContext
        let countBeforeInsert = fetchUsers(fromContext: context).count

        let user = User(context: context)
        user.givenName  = "testInsertInViewContext"
        user.familyName = "1"

        XCTAssertNoThrow(try? context.save(), "Throw while saving.")

        let countAfterInsert = fetchUsers(fromContext: context).count

        XCTAssert(countAfterInsert - countBeforeInsert == 1)
    }

    func testInsertInBackgroundContext() {

        coreDataStack.persistentContainer.performBackgroundTask { context in

            let countBeforeInsert = self.fetchUsers(fromContext: context).count

            let user = User(context: context)
            user.givenName  = "testInsertInBackgroundContext"
            user.familyName = "1"

            XCTAssertNoThrow(try? context.save(), "Throw while saving.")

            let countAfterInsert = self.fetchUsers(fromContext: context).count

            XCTAssert(countAfterInsert - countBeforeInsert == 1)
        }
    }

    func testGenericFetch() {

        coreDataStack.persistentContainer.performBackgroundTask { context in

            let countBeforeInsert = self.fetchUsers(fromContext: context).count

            let user = User(context: context)
            user.givenName  = "testGenericFetch"
            user.familyName = "1"

            XCTAssertNoThrow(try? context.save(), "Throw while saving.")

            let array: [User] = self.fetchObjects(fromContext: context)
            let countAfterInsert = array.count

            XCTAssert(countAfterInsert - countBeforeInsert == 1)
        }
    }

    func testFetch() {

        let fetch: NSFetchRequest<User> = User.fetchRequest()

        coreDataStack.persistentContainer.performBackgroundTask { context in

            XCTAssertNoThrow(try? fetch.execute(), "Throw while fetching.")
        }
    }

    func testMockClass() {

        class MockNSManagedObjectContext : NSManagedObjectContext {

            override func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {

                return [
                    ["name" : "Arnold Arfass", "email" : "arfass@bingkitty.co.uk"],
                    ["name" : "Barry Bumfossil", "email" : "barryb@ledsham.com"],
                    ["name" : "Charles Cromulent", "email" : "charles.crom@crom-cruach.com"]
                ]
            }
        }

        let mockContext = MockNSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email ENDSWITH[cd] %@", ".co.uk")
        fetchRequest.resultType = .dictionaryResultType

        do {
            let results = try mockContext.fetch(fetchRequest)
            XCTAssertEqual(results.count, 3, "fetch request should return 3 results")

            guard let result = results.first as? [String: String] else { XCTFail("fetch request returned wrong type"); return }

            XCTAssertEqual(result["name"], "Arnold Arfass", "Name should be Arnold Arfass")
            XCTAssertEqual(result["email"], "arfass@bingkitty.co.uk", "email should be arfass@bingkitty.co.uk")

        } catch { XCTFail("Fetch request should not throw") }
    }

    // Utility functions

    func fetchUsers(fromContext context: NSManagedObjectContext) -> [User] {

        let fetch: NSFetchRequest<User> = User.fetchRequest()

        let users = try! context.fetch(fetch)

        return users
    }

    func fetchObjects<T : NSManagedObject>(fromContext context: NSManagedObjectContext) -> [T] {

        let fetch: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>

        let objects = try! context.fetch(fetch)

        return objects 
    }
}
