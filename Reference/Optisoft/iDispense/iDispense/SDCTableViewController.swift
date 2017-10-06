//
//  SDCTableViewController.swift
//  iDispense
//
//  Created by Richard Henry on 31/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

import UIKit

class SDCTableViewController: UITableViewController {

    @objc var editingLensMatrix: Bool = false

    @IBOutlet var instructionView: UIView!

    // Internal
    fileprivate lazy var addPopover: SDCAddPopupViewController = SDCAddPopupViewController(nibName: "SDCAddPopover", bundle: nil)
    fileprivate lazy var dataStore = IDDispensingDataStore.default()

    fileprivate var sdcValues: [[NSDecimalNumber]] = [[], []]
    fileprivate var values: [(NSDecimalNumber, NSDecimalNumber)] = []
    fileprivate var changesMade = false

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        loadData()
        showInstructionScreen()

        NotificationCenter.default.addObserver(self, selector: #selector(SDCTableViewController.refreshTableView(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SDCTableViewController.refreshTableView(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {

        fadeInstructionScreen()
    }

    override func viewDidDisappear(_ animated: Bool) {

        NotificationCenter.default.removeObserver(self)

        if changesMade { saveData() }
    }

    // MARK: Load and save

    func loadData() {

        // Load matrices from the practice details
        if let details = dataStore.practiceDetails, let sdcData = details["sdcData"] as? Data {

            // Unarchive the data and check that it is in the correct format.
            if let unarchivedData = NSKeyedUnarchiver.unarchiveObject(with: sdcData) as? [[NSDecimalNumber]] {

                // Keep the raw values so that we can save them back if there are any alterations.
                sdcValues = unarchivedData

                // Copy the correct block of editable data back into the values array.
                let valueData = editingLensMatrix ? unarchivedData[0] : unarchivedData[1]
                values = (0..<valueData.count / 2).map { let i = $0 * 2; return (valueData[i], valueData[i + 1]) }

                // The values have changed so let's reload the table view.
                tableView.reloadData()
            }
        }
    }
    
    func saveData() {

        // This is the block we'll use to copy the edited values into the correct array.
        let copyFunc = {(arr: inout [NSDecimalNumber]) in

            // Clear the array and copy the newly edited values into it
            arr.removeAll()
            for num in self.values { arr.append(num.0); arr.append(num.1) }
        }

        // Call the copy function depending on whether this is the lens or frame array.
        if editingLensMatrix { copyFunc(&sdcValues[0]) } else { copyFunc(&sdcValues[1]) }

        // Put the SDC values into an NSData object and save it to the practice details
        if var details = dataStore.practiceDetails {

            details["sdcData"] = NSKeyedArchiver.archivedData(withRootObject: sdcValues)

            dataStore.setPracticeDetails(details)
            dataStore.save()
        }
    }

    // MARK: Instruction view

    func showInstructionScreen() {

        if (UserDefaults.standard.object(forKey: "show_welcome_screen_preference") as AnyObject).boolValue ?? false {

            // Load the view
            UINib(nibName: "SDCInstructions", bundle: nil).instantiate(withOwner: self, options: nil)
            instructionView.translatesAutoresizingMaskIntoConstraints = false
            instructionView.alpha = 0

            if let parentView = self.navigationController?.view {

                parentView.insertSubview(instructionView, aboveSubview: parentView)
                parentView.bringSubview(toFront: instructionView)

                // Add the constraints
                NSLayoutConstraint(item: parentView, attribute: .centerX, relatedBy: .equal, toItem: instructionView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
                NSLayoutConstraint(item: parentView, attribute: .centerY, relatedBy: .equal, toItem: instructionView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true

                UIView.animate(withDuration: 0.42, animations: { self.instructionView.alpha = 1 }, completion: nil)
            }
        }
    }

    func fadeInstructionScreen() {

        UIView.animate(withDuration: 0.23, animations: { self.instructionView.alpha = 0 }, completion: { (finished: Bool) in

            self.instructionView.isHidden = true
            self.instructionView.removeFromSuperview()
        })
    }

    // MARK: Actions

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {

        fadeInstructionScreen()
        
        addPopover.modalPresentationStyle = .popover
        addPopover.preferredContentSize = addPopover.view.frame.size

        addPopover.adjustForValues(values)

        addPopover.addBandBlock = { [weak self] (vc: SDCAddPopupViewController) in guard let s = self else { return }

            let ub = NSDecimalNumber(string: vc.upperBandTextField.text)
            let bc = NSDecimalNumber(string: vc.bandCostTextField.text)

            s.values.append((ub, bc))

            vc.adjustForValues(s.values)
            vc.clearTextFieldsAfterEntry()

            s.tableView.reloadData()

            let ip = IndexPath(row: s.tableView.numberOfRows(inSection: 0) - 1, section: 0)
            s.tableView.scrollToRow(at: ip, at: .top, animated: true)
            s.changesMade = true
        }

        if let poc = addPopover.popoverPresentationController {

            poc.barButtonItem = sender
            poc.permittedArrowDirections = .any

            DispatchQueue.main.async {

                self.present(self.addPopover, animated: true, completion: nil)
            }
        }
    }

    @IBAction func trashButtonTapped(_ sender: UIBarButtonItem) {

        fadeInstructionScreen()

        if values.count > 0 {

            values.removeLast()
            tableView.reloadData()

            changesMade = true
        }

        addPopover.adjustForValues(values)
    }

    // MARK: Notifications

    func refreshTableView(_ note: Notification) {

        scrollToVisible(self.tableView)
    }

    // MARK: Scroll utilities

    func scrollToVisible(_ tv: UITableView) {

        let rowsInSection = tv.numberOfRows(inSection: 0)

        if rowsInSection > 0 {

            let ip = IndexPath(row: rowsInSection - 1, section: 0)
            tv.scrollToRow(at: ip, at: .top, animated: true)
        }
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return values.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)

        if let cell = cell as? SDCTableCell {

            let row = (indexPath as NSIndexPath).row
            let isLastCell = row + 1 == values.count

            let loRange = NumberFormatter.localizedString(from: values[row].0, number: .currency)

            let preAmble = "Range \(row): "

            cell.rangeTextField.text = isLastCell ? "\(preAmble)\(loRange) and over." : "\(preAmble)\(loRange) - \(NumberFormatter.localizedString(from: values[row + 1].0, number: .currency))"
            cell.costTextField.text = "Fee: \(NumberFormatter.localizedString(from: values[row].1, number: .currency))"
        }

        return cell
    }
}

// MARK: - Add Band popup VC

class SDCAddPopupViewController : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var upperBandTextField: UITextField!
    @IBOutlet weak var bandCostTextField: UITextField!
    @IBOutlet weak var fromBandLabel: UILabel!
    @IBOutlet weak var addBandButton: UIButton!

    var addBandBlock : ((_ vc: SDCAddPopupViewController) -> Void)?

    fileprivate var connected = false

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        upperBandTextField.delegate = self
        bandCostTextField.delegate = self;

        connected = true
    }

    // MARK: Actions

    @IBAction func addBandButtonTapped(_ sender: UIButton) {

        addBandBlock?(self)
    }

    // MARK: UI Adjustments

    func adjustForValues(_ values: [(NSDecimalNumber, NSDecimalNumber)]) {

        if !connected { return }
        
        let firstBand = values.count == 0

        upperBandTextField.isEnabled = !firstBand
        if firstBand { upperBandTextField.text = "0" }

    }

    func clearTextFieldsAfterEntry() {

        upperBandTextField.text = nil
        bandCostTextField.text = nil

        upperBandTextField.becomeFirstResponder()
    }

    // MARK: <UITextFieldDelegate>

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        return true
    }
}

// MARK: - Table cell

class SDCTableCell : UITableViewCell {

    @IBOutlet weak var rangeTextField: UILabel!
    @IBOutlet weak var costTextField: UILabel!
}
