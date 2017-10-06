//
//  RxDetailViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 21/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class RxDetailViewController: UIViewController {

    // MARK: Properties

    var order: Order!
    var type: Int = 0

    var saveBlock: (() -> Void)?

    @IBOutlet var rxPickerController: RxPickerController!
    @IBOutlet weak var prescriptionDateLabel: UILabel!
    @IBOutlet weak var labelContainerView: UIView!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        if let rx = order.patient?.prescriptions?.first {

            setupPickerController(rx)
            layoutPrescriptionPickers(rx)

            prescriptionDateLabel.text = "\(DateFormatter.localizedString(from: rx.examDate ?? Date(), dateStyle: .long, timeStyle: .none))"

        }
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        saveBlock?()
    }

    // MARK: Setup

    func layoutPrescriptionPickers(_ rx: Prescription) {

        func addSubviewAndAlignTopAndHeight(_ viewToAlign: UIView) {

            labelContainerView.addSubview(viewToAlign)
            viewToAlign.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint(item: viewToAlign, attribute: .height, relatedBy: .equal, toItem: labelContainerView, attribute: .height, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: viewToAlign, attribute: .top, relatedBy: .equal, toItem: labelContainerView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        }

        // Insert the bookends…
        let bookends = (left: UIView(frame: CGRect.zero), right: UIView(frame: CGRect.zero))
        addSubviewAndAlignTopAndHeight(bookends.left)
        NSLayoutConstraint(item: bookends.left, attribute: .left, relatedBy: .equal, toItem: labelContainerView, attribute: .left, multiplier: 1.0, constant: 0).isActive = true

        addSubviewAndAlignTopAndHeight(bookends.right)
        NSLayoutConstraint(item: bookends.right, attribute: .width, relatedBy: .equal, toItem: bookends.left, attribute: .width, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bookends.right, attribute: .right, relatedBy: .equal, toItem: labelContainerView, attribute: .right, multiplier: 1.0, constant: 0).isActive = true

        var subViewCount = 0
        var masterSubView: UIView!
        let lastSubviewIndex = rxPickerController.componentTypes.count - 1
        var leftSubview = bookends.left

        for type in rxPickerController.componentTypes {

            // Insert label centring view…
            let labelCentringView = UIView(frame: CGRect.zero)
            addSubviewAndAlignTopAndHeight(labelCentringView)

            if subViewCount == 0 {

                masterSubView = labelCentringView

                NSLayoutConstraint(item: labelCentringView, attribute: .left, relatedBy: .equal, toItem: bookends.left, attribute: .right, multiplier: 1.0, constant: 0).isActive = true
                NSLayoutConstraint(item: labelCentringView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 123).isActive = true

            } else if subViewCount == lastSubviewIndex {

                NSLayoutConstraint(item: labelCentringView, attribute: .left, relatedBy: .equal, toItem: leftSubview, attribute: .right, multiplier: 1.0, constant: 0).isActive = true
                NSLayoutConstraint(item: labelCentringView, attribute: .right, relatedBy: .equal, toItem: bookends.right, attribute: .left, multiplier: 1.0, constant: 0).isActive = true
                NSLayoutConstraint(item: labelCentringView, attribute: .width,  relatedBy: .equal, toItem: masterSubView, attribute: .width, multiplier: 1.0, constant: 0).isActive = true

            } else {

                NSLayoutConstraint(item: labelCentringView, attribute: .left, relatedBy: .equal, toItem: leftSubview, attribute: .right, multiplier: 1.0, constant: 0).isActive = true
                NSLayoutConstraint(item: labelCentringView, attribute: .width,  relatedBy: .equal, toItem: masterSubView, attribute: .width, multiplier: 1.0, constant: 0).isActive = true
            }

            // Add label to the centring view…
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.attributedText = NSAttributedString(string: type.name, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)])

            labelCentringView.addSubview(label)
            NSLayoutConstraint(item: label, attribute: .centerX,  relatedBy: .equal, toItem: labelCentringView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: label, attribute: .centerY,  relatedBy: .equal, toItem: labelCentringView, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true

            subViewCount += 1
            leftSubview = labelCentringView
        }

        NSLayoutConstraint(item: bookends.left, attribute: .width, relatedBy: .equal, toItem: masterSubView, attribute: .width, multiplier: 0.25, constant: 0).isActive = true
    }

    func setupPickerController(_ rx: Prescription) {

        var sectionName = "Unknown"

        switch type {

        case 0: // Distance

            sectionName = "Base"
            rxPickerController.makeDistancePickers(rx)

            rxPickerController.selectBlock = { (isLeft: Bool, row: Int, component: Int) in

                if let sideRx = isLeft ? rx.left : rx.right {

                    switch component {

                    case 0:
                        sideRx.sph = Dioptre(iv: row, rrc: sphRangeResAndCount).value as NSNumber?

                    case 1:
                        sideRx.cyl = Dioptre(iv: row, rrc: cylRangeResAndCount).value as NSNumber?

                    case 2:
                        sideRx.axis = Double(row) as NSNumber?

                    case 3:
                        sideRx.prism = Dioptre(iv: row, rrc: psmRangeResAndCount).value as NSNumber?

                    case 4:
                        sideRx.direction = NSNumber(value: row as Int)

                    case 5:
                        sideRx.centres = NSNumber(value: self.rxPickerController.distanceValueFromindex(row, scaling: self.rxPickerController.centresBaseAndRes))
                        
                    default:break
                    }
                }
            }

        case 1: // Near

            sectionName = "Addition"
            rxPickerController.makeAddPickers(rx)

            rxPickerController.selectBlock = { (isLeft: Bool, row: Int, component: Int) in

                if let sideRx = isLeft ? rx.left : rx.right {

                    switch component {

                    case 0:
                        sideRx.add = Dioptre(iv: row, rrc: addRangeResAndCount).value as NSNumber?

                        if !isLeft {

                            // Sync the left add with the right but allow the left add to be independantly adjusted.
                            rx.left?.add = sideRx.add
                            self.rxPickerController.leftPicker.selectRow(Dioptre(dv: rx.left?.add?.doubleValue ?? 0.0, rrc: addRangeResAndCount).index, inComponent: 0, animated: true)
                        }

                    case 1:
                        sideRx.segHeight = NSNumber(value: self.rxPickerController.distanceValueFromindex(row, scaling: self.rxPickerController.segHeightBaseAndRes))

                        if !isLeft {

                            // Sync the left seg height with the right but allow the left sh to be independantly adjusted.
                            rx.left?.segHeight = sideRx.segHeight
                            self.rxPickerController.leftPicker.selectRow(row, inComponent: 1, animated: true)
                        }
                        
                    default:break
                    }
                }
            }

        default: break
        }

        navigationItem.title = "Dispense " + order.prefixedOrderNumber + " \(sectionName) Rx"
    }
}
