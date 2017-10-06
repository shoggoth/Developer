//
//  OrderDetailViewController.swift
//  iDispense
//
//  Created by Richard Henry on 21/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class OrderDetailViewController : OrderTableViewController, UITextFieldDelegate {

    // MARK: Properties

    var isNewOrder: Bool = false

    var saveBlock: (() -> Void)?
    var cancelBlock: (() -> Void)?

    // Name
    @IBOutlet weak var surnameField : UITextField!
    @IBOutlet weak var firstnameField : UITextField!

    // Popovers
    @IBOutlet weak var popoverController : PopoverController!

    // Date & Supplier
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var supplierSelectedLabel: UILabel!

    // Rx
    @IBOutlet var extendedRxCells: [CollapsibleTableViewCell]!
    @IBOutlet var extendedRxContainerViews: [UIView]!
    @IBOutlet var subRxViews: [UIView]!
    @IBOutlet var rxLabels: [UILabel]!

    // Frames
    @IBOutlet weak var frameNameField: UITextField!
    @IBOutlet weak var frameColourField: UITextField!
    @IBOutlet weak var frameSizeField: UITextField!
    @IBOutlet weak var framePriceField: UITextField!
    @IBOutlet weak var currencySymbolLabel: UILabel!
    @IBOutlet weak var orderTypeSegControl: UISegmentedControl!
    @IBOutlet weak var frameTypeSegControl: UISegmentedControl!

    // Lenses
    @IBOutlet var lensLockController: LockStateController!

    // Adjustments
    @IBOutlet weak var chargesField: UITextField!
    @IBOutlet weak var chargesDescription: UITextField!
    @IBOutlet weak var currencySymbolLabel2: UILabel!
    @IBOutlet weak var orderTotalLabel: UILabel!

    // SDC
    @IBOutlet weak var sdcButton: UIButton!

    // Status
    @IBOutlet weak var orderStatusSegControl: UISegmentedControl!

    // Notes
    @IBOutlet weak var noteTextView : NoteTextView!

    // Internal
    fileprivate lazy var pickerPopover: PickerInPopover = PickerInPopover(pickerFrame: CGRect(x: 0, y: 0, width: 320, height: 216))
    fileprivate var shareButton: UIBarButtonItem!
    fileprivate let plusMinusSymbol = "+/-"
    fileprivate let dataStore = IDDispensingDataStore.default()

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // This is the magic line of code which removes the constraint conflict.
        // I don't even. But http://stackoverflow.com/questions/25059443/
        // iOS 8 and above only.
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension

        // Set up share button
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(OrderDetailViewController.share(_:)))

        // Set up purchase notifications.
        NotificationCenter.default.addObserver(self, selector:#selector(OrderDetailViewController.purchaseNotification(_:)), name:NSNotification.Name.IDIAPProductPurchased, object: nil)

        if isNewOrder {

            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(OrderDetailViewController.cancel))
            navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(OrderDetailViewController.save)), shareButton]

            navigationItem.title = "New Dispense"

        } else {

            navigationItem.rightBarButtonItem = shareButton
            navigationItem.title = "Edit Dispense " + order.prefixedOrderNumber
        }

        // Fill in the order details
        if let patient = order.patient {

            surnameField.text = patient.surName
            firstnameField.text = patient.firstName
        }

        supplierSelectedLabel.text = self.order.supplier?.name

        // UI Setup
        insertRxDetailSubviews()
        formatDateLabel()

        // Lens and frame details
        formatFrameLabels()

        lensLockController.order = order.lensOrder
        lensLockController.setupLockButtonState()
        lensLockController.formatLensLabels()
        lensLockController.lockStateChangedBlock = { [weak self] (state: Bool) in self?.formatTotalPriceLabel() }

        // Calculate and set the price labels.
        formatTotalPriceLabel()
        chargesField.decimalNumber = order.charges ?? NSDecimalNumber.zero
        chargesDescription.text = order.chargesDescription

        // Status
        orderStatusSegControl.selectedSegmentIndex = order.status?.intValue ?? 0

        let currencySymbol = order.currencySymbol
        currencySymbolLabel.text = currencySymbol
        currencySymbolLabel2.text = currencySymbol

        chargesField.placeholder = plusMinusSymbol

        // Notes
        if let comments = order.comments { noteTextView.text = comments }
        noteTextView.endEditingBlock = { [weak self] (text: String) in if let s = self { s.order.comments = text; s.order.dateModified = Date() }}

        // Rx
        if let rx = order.patient?.prescriptions?.first {

            // Expand the add section if there is an add in the prescription
            if rx.hasAddition() {

                for cell in extendedRxCells {

                    cell.collapse(false, tableView: tableView)

                    cell.contentView.alpha = 1
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // Fill in the prescription display
        if let rx = order.patient?.prescriptions?.first {

            // Reformat the labels so that changes are reflected
            formatRxLabelsAtIndex(0, rx: rx.right)
            formatRxLabelsAtIndex(10, rx: rx.left)
        }

        // Set up SDC button (might have been changed in the settings)
        sdcButton.isEnabled =  UserDefaults.standard.bool(forKey: "sdc_active")
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // Remove us from the notification
        NotificationCenter.default.removeObserver(self)

        // If we are leaving this view and it isn't a new order, commit the edits and call the caller's save block
        if !isNewOrder && self.isMovingFromParentViewController {

            commitEditsWithCompletionBlock(saveBlock!)
        }
    }

    // MARK: Actions

    @IBAction func selectSupplier(_ sender: UIButton, forEvent event: UIEvent) {

        if event.touches(for: sender)?.first != nil {

            popoverController.popDismissCompletionBlock = { [weak self] in

                if let s = self { s.supplierSelectedLabel.text = s.order.supplier?.name }
            }

            if let navigation = popoverController.presentPopupWithViewControllerNamed("Supplier.SupplierNavigation", fromRect: sender.bounds, fromView: sender) as? UINavigationController {

                if let orderTVC = navigation.viewControllers[0] as? OrderTableViewController { orderTVC.order = order }
            }
        }
    }

    @IBAction func toggleExtendedRxSection(_ sender: UIButton) {

        for cell in extendedRxCells {

            cell.toggleCollapse(tableView)

            UIView.animate(withDuration: cell.isCollapsed ? 0.23 : 0.5, animations: { cell.contentView.alpha = cell.isCollapsed ? 0 : 1 })
        }
    }

    func save() {

        // Commit edited details that were altered in this view
        commitEditsWithCompletionBlock({

            // Dismiss this view controller
            self.presentingViewController?.dismiss(animated: true, completion: self.saveBlock)
        })
    }

    func cancel() { presentingViewController?.dismiss(animated: true, completion: cancelBlock) }

    func share(_ sender: AnyObject) {

        // Clear out all the PDFs
        IDPDFDrawer.clearPDFFilesFromDocumentFolder()

        let shareController = IDSharingController()

        // Let's not have any of the social meedja bullshit.
        let excludedActivityTypes = [ UIActivityType.assignToContact, UIActivityType.message, UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.postToWeibo ]

        // Recalculate before the share
        commitEditsWithCompletionBlock({

            shareController.shareItems(makeShareMessageFromOrder(self.order), from: self, options: ["sender" : sender, "subject" : makeEmailSubjectFromOrder(self.order), "excludeActivities" : excludedActivityTypes])
        })
    }

    func purchaseNotification(_ note: Notification) {

        // There has been a purchase so we might have to enable the share button.
        // shareButton.enabled = IDInAppPurchases.sharedIAPStore().singleUserUnlocked || IDInAppPurchases.sharedIAPStore().multiUserUnlocked
    }

    // MARK: Table view data source

    override func tableView(_ view: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (indexPath as NSIndexPath).section == 1 {

            // The decision as to which of the Rx subviews is to be displayed will be decided as the segue is sent.
            self.performSegue(withIdentifier: "pushRxDetail", sender: indexPath)

        } else if (indexPath as NSIndexPath).section == 2 || (indexPath as NSIndexPath).section == 3 {

            // Lens order selection
            let navPaths = [ "LensNavigation", "LensTreatmentNavigation", "LensTreatmentNavigation", "LensTreatmentNavigation" ]
            let isLeftLens = (indexPath as NSIndexPath).section == 3
            let labelIndex = (isLeftLens) ? (indexPath as NSIndexPath).row + 4 : (indexPath as NSIndexPath).row

            if ((indexPath as NSIndexPath).row == 4) {

                let lensDetailView = self.lensLockController.lensBlankSizeLabels[isLeftLens ? 1 : 0]

                if (lensDetailView.isEnabled) {

                    // Select the lens blank size parameters.
                    pickerPopover.ambles.post = " mm"
                    pickerPopover.ranges = [(lo: 50.0, hi: 80.0, res: 1.0)]
                    pickerPopover.selectBlocks = [{ (blankSize: Double) in

                        if let lensOrder = self.order.lensOrder {

                            if isLeftLens { lensOrder.leftBlankSize = blankSize as NSNumber? } else { lensOrder.rightBlankSize = blankSize as NSNumber? }
                        }

                        self.lensLockController.copyLockedParameters()
                        self.lensLockController.formatLensLabels()
                    }]

                    pickerPopover.present(inFrame: lensDetailView.globalViewRect(tableView), inView: tableView)
                }

            } else {

                let lensDetailView = lensLockController.lensDetailViews[labelIndex]

                if (lensDetailView.enabled) {

                    // Select the lens parameters
                    func presentLensPopupFromLabel(dismissBlock dBlock:(() -> Void)?) {

                        popoverController.popPresentCompletionBlock = { (vc: UIViewController) in

                            // If the view controller we got from the storyboard is a navigation controller…
                            if let navigation = vc as? UINavigationController {

                                // And the zeroth item is an order view controller, set the order
                                if var lensTVC = navigation.viewControllers[0] as? LensAdditions {

                                    lensTVC.isLeftLens = isLeftLens
                                    lensTVC.subType = [.None, .Tint, .Coat, .Finish][(indexPath as NSIndexPath).row]
                                }
                            }
                        }

                        popoverController.popDismissCompletionBlock = { [weak self] in

                            if let s = self {

                                // Fill in lens labels to match the alterations in the popup
                                s.lensLockController.copyLockedParameters()
                                s.lensLockController.formatLensLabels()
                                s.formatTotalPriceLabel()

                                // Do the supplied dismissal block if there is one.
                                dBlock?()
                            }
                        }

                        presentOrderPopup("Lens.\(navPaths[(indexPath as NSIndexPath).row])", presentRect: lensDetailView.detailField.globalViewRect(tableView))
                    }

                    presentLensPopupFromLabel(dismissBlock: nil)
                }
            }
        }

        // Deselect selected row
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: UI

    fileprivate func presentOrderPopup(_ viewControllerPath: String, presentRect: CGRect) {

        // If the view controller we got from the storyboard is a navigation controller…
        if let navigation = popoverController.presentPopupWithViewControllerNamed(viewControllerPath, fromRect: presentRect) as? UINavigationController {

            // And the zeroth item is an order view controller, set the order
            if let orderTVC = navigation.viewControllers[0] as? OrderTableViewController { orderTVC.order = order }
        }
    }

    fileprivate func insertRxDetailSubviews() {

        // Load the subviews from the XIB
        UINib(nibName: "RxDetailViews", bundle: nil).instantiate(withOwner: self, options: nil)

        // Prepare the dictionary for visual constraint manipulation.
        let metricsDictionary = ["space" : 0]

        // Add Rx views and constrain them
        for i in 0..<2 {

            let subView = subRxViews[i]
            let containerView = extendedRxContainerViews[i]

            subView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(subView)

            // These are hidden initially and fade in when the cell is disclosed.
            // Set their alpha to zero initially.
            if (i >= 1) { containerView.alpha = 0 }

            let viewsDictionary = ["subView" : subView]
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(space)-[subView]-(space)-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(space)-[subView]-(space)-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        }
    }

    fileprivate func formatTotalPriceLabel() {

        orderTotalLabel.text = order.totalPriceString()
    }

    fileprivate func formatDateLabel() {

        dateLabel.text = order.creationDateString()
    }

    fileprivate func formatFrameLabels() {

        if let frameOrder = order.frameOrder, let frame = frameOrder.frame {

            frameNameField.text = frame.name
            framePriceField.decimalNumber = frame.price ?? NSDecimalNumber.zero
            frameSizeField.text = frame.measurements
            frameColourField.text = frame.style

            orderTypeSegControl.selectedSegmentIndex = frameOrder.orderType?.intValue ?? 0
            frameTypeSegControl.selectedSegmentIndex = frame.type?.intValue ?? 0
        }
    }

    fileprivate func formatRxLabelsAtIndex(_ index: Int, rx: EyePrescription?) {

        guard let rx = rx else { return }

        // Base
        Dioptre.zeroSymbol = "Plano"
        rxLabels[index].attributedText = Dioptre(dv: rx.sph?.doubleValue ?? 0.0, rrc: sphRangeResAndCount).dioptreAttributedString()
        Dioptre.zeroSymbol = "0"
        rxLabels[index + 1].attributedText = Dioptre(dv: rx.cyl?.doubleValue ?? 0.0, rrc:cylRangeResAndCount).dioptreAttributedString()
        rxLabels[index + 2].text = String.localizedStringWithFormat("%.f", rx.axis?.doubleValue ?? 0.0)
        rxLabels[index + 3].attributedText = Dioptre(dv: rx.prism?.doubleValue ?? 0.0, rrc:psmRangeResAndCount).dioptreAttributedString()
        rxLabels[index + 4].text = PrismDirection(rawValue: Int(rx.direction ?? 0))?.directionString()
        rxLabels[index + 5].text = String.localizedStringWithFormat("%.1f mm", rx.centres?.doubleValue ?? 0.0)

        // Addition
        rxLabels[index + 6].attributedText = Dioptre(dv: rx.add?.doubleValue ?? 0.0, rrc: addRangeResAndCount).dioptreAttributedString()
        rxLabels[index + 7].text = String.localizedStringWithFormat("%.1f mm", rx.segHeight?.doubleValue ?? 0.0)
        rxLabels[index + 8].text = String.localizedStringWithFormat("%.f mm", rx.segSize?.doubleValue ?? 0.0)
        rxLabels[index + 9].text = String.localizedStringWithFormat("%.1f mm", rx.addCentres?.doubleValue ?? 0.0)
    }

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)

        if segue.identifier == "pushRxDetail" {

            // Rx detail view controllers for distance, near and intermediate.
            if let detailViewController = segue.destination as? RxDetailViewController {

                detailViewController.order = order
                detailViewController.type = ((sender as! IndexPath) as NSIndexPath).row
                detailViewController.saveBlock = {

                    // Save the object and display the newly added record at the bottom of the table.
                    // IDDispensingDataStore.defaultDataStore().save()
                }
            }

        } else if segue.identifier == "pushSDCDetail" {

            // SDC View controller needs an order
            if let detailViewController = segue.destination as? SDCPreviewViewController {

                detailViewController.order = order
            }
        }
    }

    // MARK: Data manipulation

    func commitEditsWithCompletionBlock(_ completionBlock: @escaping ()->()?) {

        // Order type UI values
        let otsc = orderTypeSegControl.selectedSegmentIndex

        // Frame UI values
        let fn = frameNameField.text;
        let fp = framePriceField.decimalNumber;
        let fs = frameSizeField.text;
        let fc = frameColourField.text;
        let ft = NSNumber(value: frameTypeSegControl.selectedSegmentIndex as Int);

        // Patient UI values
        let ps = surnameField.text;
        let pf = firstnameField.text;

        // Charges UI values
        let oc = chargesField.decimalNumber;
        let cd = chargesDescription.text;

        // Order status UI values
        let os = NSNumber(value: orderStatusSegControl.selectedSegmentIndex as Int)

        self.dataStore.perform({ (ds: CDSDataStore) in

            if let order = self.order {

                var orderModified = false

                // Frame
                if let frameOrder = order.frameOrder {

                    // Order type
                    let ot = NSNumber(value: otsc as Int); if ot != frameOrder.orderType { frameOrder.orderType = ot }

                    if let frame = frameOrder.frame ?? NSEntityDescription.insertNewObject(forEntityName: "Frame", into: ds.moc) as? Frame {

                        // Have there been any modifications to the frame?
                        var frameModified = false

                        if frame != frameOrder.frame { frameOrder.frame = frame; frameModified = true }

                        // Purchase
                        if frame.name != fn { frame.name = fn; frameModified = true }
                        if frame.price != fp { frame.price = fp; frameModified = true }

                        // Parameters
                        if frame.measurements != fs { frame.measurements = fs; frameModified = true }
                        if frame.style != fc { frame.style = fc; frameModified = true }
                        if frame.type != ft { frame.type = ft; frameModified = true }

                        // Update the modification date if anything has changed
                        if frameModified {

                            frame.dateModified = Date()
                            orderModified = true
                        }
                    }
                }

                // Save details that were altered in this view
                if let patient = order.patient {

                    if patient.surName != ps { patient.surName = ps; orderModified = true }
                    if patient.firstName != pf { patient.firstName = pf; orderModified = true }
                }

                // Charges
                if order.charges != oc { order.charges = oc; orderModified = true }
                if order.chargesDescription != cd { order.chargesDescription = cd; orderModified = true }

                // Status
                if order.status != os { order.status = os; orderModified = true }
                
                // Trigger a modification on the order by setting the modification date to the current time.
                if orderModified { order.dateModified = Date() }
            }
            
            return nil
            
            }, withCompletion: { _ in completionBlock() })
    }

    // MARK: <UITextFieldDelegate>

    func textFieldDidEndEditing(_ textField: UITextField) {

        switch textField {

        case chargesField:
            order.charges = textField.decimalNumber
            formatTotalPriceLabel()

        case framePriceField:
            commitEditsWithCompletionBlock({ self.formatTotalPriceLabel() })

        default:break
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        return true
    }
}

// MARK: - UIView Utilities (private)

private extension UIView {
    
    func globalViewRect(_ inView: UIView) -> CGRect {
        
        var f = self.frame
        f.origin = inView.convert(f.origin, from: self)
        
        return f
    }

    func removeAllSubviews() {

        for subview in subviews { subview.removeFromSuperview() }
    }
}
