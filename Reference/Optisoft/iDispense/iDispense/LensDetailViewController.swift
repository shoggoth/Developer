//
//  LensDetailViewController.swift
//  iDispense
//
//  Created by Richard Henry on 28/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class LensDetailViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    // MARK: Properties

    var order: LensOrder?
    var whichLens: WhichLens = .Left

    var lens: Lens?

    @IBOutlet weak var lensNameField: UITextField!
    @IBOutlet weak var lensMaterialSegControl: UISegmentedControl!
    @IBOutlet weak var lensTypeSegControl: UISegmentedControl!
    @IBOutlet weak var lensPriceField: UITextField!

    @IBOutlet weak var lensManufacturerPicker: UIPickerView!
    @IBOutlet weak var newLensManufacturerField: UITextField!
    @IBOutlet weak var newLensManufacturerButton: UIButton!

    private var lensManufacturerPickerHandler = PickerHandler<LensManufacturer>(entityName: "LensManufacturer", key: "name")
    private var cancelled = false

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Set the target of the cancel button after creating it.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAndDismiss:")

        // Set up pickers and the handlers for them
        lensManufacturerPickerHandler.nameGetterBlock = { (object: LensManufacturer) in return object.name }
        lensManufacturerPicker.dataSource = self
        lensManufacturerPicker.delegate = self

        // Set initial state of the buttons
        newLensManufacturerButton.enabled = false
        newLensManufacturerField.delegate = self

        // If this is an edit of an existing lens, fill in the details
        if let lens = self.lens {

            navigationItem.title = "Edit lens \(lens.name)"

            selectLensManufacturer(lens.manufacturer)
            lensNameField.text = "\(lens.name)"
            lensPriceField.text = "\(lens.price)"
            lensMaterialSegControl.selectedSegmentIndex = Int(lens.material)
            lensTypeSegControl.selectedSegmentIndex = Int(lens.visionType)
        }
    }

    override func viewWillDisappear(animated: Bool) {

        super.viewWillDisappear(animated)

        // Has the add operation been cancelled?
        if cancelled { return }

        // Check that a lens name has been supplied at least
        let lensName = lensNameField.text; if lensName.isEmpty { return }

        let dataStore = IDDispensingDataStore.defaultDataStore()

        if let lens = self.lens {

            lens.name = lensNameField.text
            lens.price = (lensPriceField.text as NSString).floatValue

            lens.material = Int16(lensMaterialSegControl.selectedSegmentIndex)
            lens.visionType = Int16(lensTypeSegControl.selectedSegmentIndex)
            lens.manufacturer = lensManufacturerPickerHandler.selected

        } else {

            // Add the new lens to the database and link it to the current order.
            if let lens = dataStore.addLensWithName(lensNameField.text, manuName: lensManufacturerPickerHandler.selected.name, price: (lensPriceField.text as NSString).floatValue, material: lensMaterialSegControl.selectedSegmentIndex, visType: lensTypeSegControl.selectedSegmentIndex) {

                switch self.whichLens {

                case .Left:
                    order?.leftLens = lens

                case .Right:
                    order?.rightLens = lens

                case .Both:
                    order?.leftLens = lens
                    order?.rightLens = lens
                }
            }
        }

        // Save changes
        dataStore.save()
    }

    // MARK: Actions

    func cancelAndDismiss(sender: UIBarButtonItem) {

        cancelled = true

        // Dismiss this view controller
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func materialChanged(sender: UISegmentedControl) {
    }

    @IBAction func lensTypeChanged(sender: UISegmentedControl) {
    }

    @IBAction func addLensManufacturer(sender: UIButton) {

        // Create the new lens manufacturer
        let newLensManufacturer = IDDispensingDataStore.defaultDataStore().addLensManufacturerNamed(newLensManufacturerField.text) as LensManufacturer

        lensManufacturerPickerHandler.fetch()
        lensManufacturerPicker.reloadAllComponents()

        selectLensManufacturer(newLensManufacturer)

        newLensManufacturerField.text = ""
        newLensManufacturerButton.enabled = false
    }

    // MARK: Text View Delegate

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        let length = count(textField.text) - range.length + count(string)

        newLensManufacturerButton.enabled = length > 0

        return true
    }

    // MARK: Picker view proxy

    // Swift Generics can't be used as a delegate or data source from ObjC so we'll have to proxy them buggers

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        lensManufacturerPickerHandler.selectedIndex = row
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {

        return lensManufacturerPickerHandler.numberOfComponentsInPickerView(pickerView)
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return lensManufacturerPickerHandler.pickerView(pickerView, numberOfRowsInComponent: component)
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {

        return lensManufacturerPickerHandler.pickerView(pickerView, titleForRow: row, forComponent: component)
    }
    
    // MARK: UI
    
    private func selectLensManufacturer(manufacturer: LensManufacturer) {
        
        let i = lensManufacturerPickerHandler.indexOfObject(manufacturer)
        lensManufacturerPickerHandler.selectedIndex = i
        lensManufacturerPicker.selectRow(i, inComponent: 0, animated: true)
        
    }
}
