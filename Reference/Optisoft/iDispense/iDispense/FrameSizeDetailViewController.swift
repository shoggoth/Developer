//
//  FrameDetailViewController.swift
//  iDispense
//
//  Created by Richard Henry on 28/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class FrameSizeDetailViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    // MARK: Properties

    var order: Order!

    @IBOutlet weak var frameNameField: UITextField!
    @IBOutlet weak var frameTypeSegControl: UISegmentedControl!
    @IBOutlet weak var frameSizeField:   UITextField!
    @IBOutlet weak var frameLengthField: UITextField!
    @IBOutlet weak var frameBridgeField: UITextField!
    @IBOutlet weak var frameColourField: UITextField!
    @IBOutlet weak var framePriceField:  UITextField!

    @IBOutlet weak var frameManufacturerPicker: UIPickerView!
    @IBOutlet weak var newFrameManufacturerField: UITextField!
    @IBOutlet weak var newFrameManufacturerButton: UIButton!

    private var frameManufacturerPickerHandler = PickerHandler<FrameManufacturer>(entityName: "FrameManufacturer", key: "name")

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Set up pickers and the handlers for them
        frameManufacturerPickerHandler.nameGetterBlock = { (object: FrameManufacturer) in return object.name }
        frameManufacturerPicker.dataSource = self
        frameManufacturerPicker.delegate = self

        // Set initial state of the buttons
        newFrameManufacturerButton.enabled = false
        newFrameManufacturerField.delegate = self

        IDDispensingDataStore.defaultDataStore().createFrameSizeWithSize(1.23, length: 4.56, bridge: 7.89)
        IDDispensingDataStore.defaultDataStore().save()

        // Create new frame
        //order.frame = NSEntityDescription.insertNewObjectForEntityForName("Frame", inManagedObjectContext: IDDispensingDataStore.defaultDataStore().managedObjectContext) as Frame
    }

    override func viewWillDisappear(animated: Bool) {

        super.viewWillDisappear(animated)

//        if let frame = order.frame {
//
//            // Fill in the frame details
//            frame.name = frameNameField.text
//
//            // Fill in the default frame size
//            IDDispensingDataStore.defaultDataStore().createFrameSizeWithSize(1.23, length: 4.56, bridge: 7.89)
//
//            if let frameSize = NSEntityDescription.insertNewObjectForEntityForName("FrameSize", inManagedObjectContext: IDDispensingDataStore.defaultDataStore().managedObjectContext) as? FrameSize {
//
//                frameSize.size = (frameSizeField.text as NSString).floatValue
//                frameSize.length = (frameLengthField.text as NSString).floatValue
//                frameSize.bridge = (frameBridgeField.text as NSString).floatValue
//
//                frame.sizes = NSSet(object: frameSize)
//            }
//
//            IDDispensingDataStore.defaultDataStore().save()
//        }
    }
    
    // MARK: Actions

    @IBAction func frameTypeChanged(sender: UISegmentedControl) {

        println("Frame type changed.")
    }

    @IBAction func addFrameManufacturer(sender: UIButton) {

        let newFrameManufacturer = IDDispensingDataStore.defaultDataStore().createFrameManufacturerNamed(newFrameManufacturerField.text) as FrameManufacturer

        frameManufacturerPickerHandler.fetch()
        frameManufacturerPicker.reloadAllComponents()

        newFrameManufacturerField.text = ""
    }

    // MARK: Text View Delegate

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        let length = countElements(textField.text) - range.length + countElements(string)

        newFrameManufacturerButton.enabled = length > 0

        return true
    }

    // MARK: Picker view proxy

    // Swift Generics can't be used as a delegate or data source from ObjC so we'll have to proxy them buggers

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {

        if pickerView == frameManufacturerPicker {

            return frameManufacturerPickerHandler.numberOfComponentsInPickerView(pickerView)

        } else { return 0 }
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if pickerView == frameManufacturerPicker {

            return frameManufacturerPickerHandler.pickerView(pickerView, numberOfRowsInComponent: component)

        } else { return 0 }
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {

        if pickerView == frameManufacturerPicker {

            return frameManufacturerPickerHandler.pickerView(pickerView, titleForRow: row, forComponent: component)

        } else { return "None" }
    }
}
