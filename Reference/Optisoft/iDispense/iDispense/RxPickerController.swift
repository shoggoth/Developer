//
//  RxPickerController.swift
//  iDispense
//
//  Created by Richard Henry on 22/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

enum RXPickerComponentTypes { case dioptre, angle, distance, direction }

let sphRangeResAndCount: RangeResAndCount = (-30, 0.25, 241)
let cylRangeResAndCount: RangeResAndCount = (-10, 0.25, 81)
let psmRangeResAndCount: RangeResAndCount = (0, 0.25, 81)
let addRangeResAndCount: RangeResAndCount = (0, 0.25, 41)

class RxPickerController : NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: Properties

    var selectBlock: ((Bool, Int, Int) -> Void)?
    var componentTypes: [(name: String, type: RXPickerComponentTypes, scale: RangeResAndCount?)] = []

    // MARK: Constants

    let centresBaseAndRes: RangeResAndCount = (20.0, 0.5, 41)
    let segHeightBaseAndRes: RangeResAndCount = (5.0, 0.5, 61)
    let segSizeBaseAndRes: RangeResAndCount = (15.0, 1.0, 25)

    // MARK: Utility functions

    func indexFromDistanceValue(_ distance: Double, scaling: RangeResAndCount) -> Int { return Int((distance - scaling.base) / scaling.resolution) }
    func distanceValueFromindex(_ index: Int, scaling: RangeResAndCount) -> Double { return Double(index) * scaling.resolution + scaling.base  }

    // UI

    @IBOutlet weak var leftPicker : UIPickerView!
    @IBOutlet weak var rightPicker : UIPickerView!

    // MARK: Actions

    func makeDistancePickers(_ rx: Prescription) {

        componentTypes = [ ("Sph", .dioptre, sphRangeResAndCount), ("Cyl", .dioptre, cylRangeResAndCount), ("Axis", .angle, nil), ("Prism", .dioptre, psmRangeResAndCount), ("Base", .direction, nil), ("Centres", .distance, centresBaseAndRes) ]

        func pickerFunc(_ picker: UIPickerView, eye: EyePrescription?) {

            if let eye = eye {

                picker.selectRow(Dioptre(dv: eye.sph?.doubleValue ?? 0.0, rrc: sphRangeResAndCount).index, inComponent: 0, animated: true)
                picker.selectRow(Dioptre(dv: eye.cyl?.doubleValue ?? 0.0, rrc: cylRangeResAndCount).index, inComponent: 1, animated: true)
                picker.selectRow(eye.axis?.intValue ?? 0, inComponent: 2, animated: true)
                picker.selectRow(Dioptre(dv: eye.prism?.doubleValue ?? 0.0, rrc: psmRangeResAndCount).index, inComponent: 3, animated: true)
                picker.selectRow(Int(eye.direction ?? 0), inComponent: 4, animated: true)
                picker.selectRow(indexFromDistanceValue(eye.centres?.doubleValue ?? 0.0, scaling: centresBaseAndRes), inComponent: 5, animated: true)
            }
        }

        pickerFunc(rightPicker, eye: rx.right)
        pickerFunc(leftPicker, eye: rx.left)
    }

    func makeAddPickers(_ rx: Prescription) {

        componentTypes = [ ("Add", .dioptre, addRangeResAndCount), ("Height", .distance, segHeightBaseAndRes) ]

        func pickerFunc(_ picker: UIPickerView, eye: EyePrescription?) {

            picker.selectRow(Dioptre(dv: eye?.add?.doubleValue ?? 0.0, rrc: addRangeResAndCount).index, inComponent: 0, animated: true)
            picker.selectRow(indexFromDistanceValue(eye?.segHeight?.doubleValue ?? 0.0, scaling: segHeightBaseAndRes), inComponent: 1, animated: true)
        }

        pickerFunc(rightPicker, eye: rx.right)
        pickerFunc(leftPicker, eye: rx.left)
    }

    // MARK: UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return componentTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        switch (componentTypes[component].type) {

        case .dioptre, .distance:
            return componentTypes[component].scale?.count ?? 1

        case .angle:
            return 181

        case .direction:
            return 4
        }
    }

    // MARK: UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {

        return pickerView.frame.size.width / CGFloat(componentTypes.count + 1)
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {

        return pickerView.frame.size.height * 0.2
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {

        switch (componentTypes[component].type) {

        case .dioptre:
            Dioptre.zeroSymbol = (component == 0) ? "Plano" : "0"
            return Dioptre(iv: row, rrc:componentTypes[component].scale ?? (-10, 1.0, 20)).dioptreAttributedString()

        case .angle:
            return NSAttributedString(string: "\(row)")

        case .distance:
            if let scale = componentTypes[component].scale {

                if scale.resolution - floor(scale.resolution) != 0.0 {

                    return NSAttributedString(string: String.localizedStringWithFormat(scale.resolution == 0.5 ? "%.1f mm" : "%.2f mm", scale.base + Double(row) * scale.resolution))

                } else {

                    return NSAttributedString(string: String.localizedStringWithFormat("%d mm", Int(scale.base + Double(row) * scale.resolution)))
                }

            } else { return NSAttributedString(string: "0") }
            
        case .direction:
            return NSAttributedString(string: PrismDirection(rawValue: row)?.directionString() ?? "???")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectBlock?(pickerView == leftPicker, row, component)
    }
}
