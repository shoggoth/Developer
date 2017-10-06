//
//  PickerInPopover.swift
//  iDispense
//
//  Created by Richard Henry on 05/02/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class PickerInPopover: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: Properties

    var selectBlocks: [((_ picked: Double) -> Void)]?
    var ranges: [(lo: Double, hi: Double, res: Double)] = []
    var ambles = (pre: "", post: "")

    fileprivate var popoverController: UIPopoverController
    fileprivate var picker : UIPickerView


    // MARK: Initialisation

    init(pickerFrame: CGRect) {

        // Initial values
        picker = UIPickerView()

        // Prepare the popover VC
        let popoverContent = UIViewController()
        let popoverView = UIView()

        picker.frame = pickerFrame

        popoverView.addSubview(picker)

        popoverContent.view = popoverView
        popoverContent.preferredContentSize = CGSize(width: 320, height: 216)

        popoverController = UIPopoverController(contentViewController: popoverContent)
        popoverController.contentSize = pickerFrame.size

        super.init()

        picker.delegate = self
    }

    // MARK: Presentation

    func present(inFrame frame: CGRect, inView view: UIView) {

        popoverController.present(from: frame, in: view, permittedArrowDirections: .any, animated: true)
    }

    // MARK: Popover delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return ranges.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        let range = ranges[component]
        return Int((range.hi - range.lo + range.res) / range.res)
    }

    // MARK: UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        let range = ranges[component]
        return "\(ambles.pre)\(range.lo + Double(row) * range.res)\(ambles.post)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let range = ranges[component]
        selectBlocks?[component](Double(row) * range.res + range.lo)
    }
}
