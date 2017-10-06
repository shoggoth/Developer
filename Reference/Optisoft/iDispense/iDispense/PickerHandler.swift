//
//  PickerHandler.swift
//  iDispense
//
//  Created by Richard Henry on 11/02/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class PickerHandler <DataType: AnyObject> : NSObject, UIPickerViewDelegate, NSFetchedResultsControllerDelegate {

    // MARK: Properties
    var selectedIndex = 0
    var selected : DataType { get { return fetchedResults[selectedIndex] } }

    var nameGetterBlock: ((object: DataType) -> String)?

    // Class local
    private var fetchedResultsController: NSFetchedResultsController!
    private var fetchedResults: [DataType] = []

    init(entityName: String, key: String, sortAscending: Bool = true) {

        super.init()

        // Create and configure a fetch request with an entity type to fetch.
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: IDDispensingDataStore.defaultDataStore().managedObjectContext)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: key, ascending: sortAscending)]

        // We are going to be using the results of the fetch in a table so let's have a small batch size
        fetchRequest.fetchBatchSize = 23

        // Create the fetched results controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: IDDispensingDataStore.defaultDataStore().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        fetch()
    }

    // MARK: Data fetch

    func fetch() {

        try! fetchedResultsController.performFetch()

        fetchedResults = fetchedResultsController.fetchedObjects as! [DataType]
    }

    func indexOfObject(object: DataType) -> Int {

        return (fetchedResults as NSArray).indexOfObject(object)
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if let sectionInfo = fetchedResultsController?.sections {

            return sectionInfo[component].numberOfObjects
        }

        return 0
    }

    // MARK: Picker view delegate

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return nameGetterBlock?(object: fetchedResults[row]) ?? "None"
    }
}

