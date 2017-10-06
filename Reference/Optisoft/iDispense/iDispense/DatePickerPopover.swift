//
//  DatePickerPopover.swift
//  iDispense
//
//  Created by Richard Henry on 05/02/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class DatePickerPopover: NSObject, UIPopoverControllerDelegate {

    // MARK: Properties

    var dateSelectBlock: ((_ date: Date) -> Void)?

    fileprivate var popoverController: UIPopoverController
    fileprivate var datePicker : UIDatePicker

    // MARK: Initialisation

    init(pickerFrame: CGRect) {

        // Initial values
        datePicker = UIDatePicker()

        // Prepare the popover VC
        let popoverContent = UIViewController()
        let popoverView = UIView()

        datePicker.frame = pickerFrame
        datePicker.datePickerMode = .date

        popoverView.addSubview(datePicker)

        popoverContent.view = popoverView

        popoverController = UIPopoverController(contentViewController: popoverContent)
        popoverController.contentSize = pickerFrame.size

        super.init()

        popoverController.delegate = self
    }

    // MARK: Presentation

    func present(inFrame frame: CGRect, inView view: UIView, initialDate: Date) {

        datePicker.date = initialDate
        popoverController.present(from: frame, in: view, permittedArrowDirections: .any, animated: true)
    }

    // MARK: Popover delegate
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {

        dateSelectBlock?(datePicker.date)
    }
}
