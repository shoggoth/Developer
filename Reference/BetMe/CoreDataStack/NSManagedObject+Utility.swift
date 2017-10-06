//
//  NSManagedObject+Utility.swift
//  BetMe
//
//  Created by Rich Henry on 18/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import CoreData

extension NSManagedObject {

    public func deleteAndSave() {

        if let objectContext = self.managedObjectContext {

            objectContext.perform {

                objectContext.delete(self)

                try! objectContext.save()
            }
        }
    }
}
