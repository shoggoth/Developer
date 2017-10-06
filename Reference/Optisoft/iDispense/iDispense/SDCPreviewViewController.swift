//
//  SDCPreviewViewController.swift
//  iDispense
//
//  Created by Richard Henry on 06/07/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

import UIKit

class SDCPreviewViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    internal var order:Order!

    fileprivate var shareButton: UIBarButtonItem!
    //private let dataStore = IDDispensingDataStore.defaultDataStore()

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let pdfOrder = IDPDFSDC()
        let pdfURL = pdfOrder.drawOrder(forPreview: order)

        webView.scalesPageToFit = true
        webView.loadRequest(URLRequest(url: pdfURL!))

        // Set up share button
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(SDCPreviewViewController.share(_:)))
        shareButton.isEnabled = IDInAppPurchases.sharedIAPStore().singleUserUnlocked || IDInAppPurchases.sharedIAPStore().multiUserUnlocked
        navigationItem.rightBarButtonItem = shareButton

        // Set up purchase notifications.
        NotificationCenter.default.addObserver(self, selector:#selector(SDCPreviewViewController.purchaseNotification(_:)), name:NSNotification.Name.IDIAPProductPurchased, object: nil)
    }

    func share(_ sender: AnyObject) {

        // Clear out all the PDFs
        IDPDFDrawer.clearPDFFilesFromDocumentFolder()

        let shareController = IDSharingController()

        // Let's not have any of the social meedja bullshit.
        let excludedActivityTypes = [ UIActivityType.assignToContact, UIActivityType.message, UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.postToWeibo ]

        // Recalculate before the share
        shareController.shareItems(makeSDCShareMessageFromOrder(self.order), from: self, options: ["sender" : sender, "subject" : makeEmailSubjectFromOrder(self.order), "excludeActivities" : excludedActivityTypes])
    }

    func purchaseNotification(_ note: Notification) {

        // There has been a purchase so we might have to enable the share button.
        shareButton.isEnabled = IDInAppPurchases.sharedIAPStore().singleUserUnlocked || IDInAppPurchases.sharedIAPStore().multiUserUnlocked
    }
}
