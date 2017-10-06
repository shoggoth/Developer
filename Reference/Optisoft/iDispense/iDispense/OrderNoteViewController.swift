//
//  OrderNoteViewController.swift
//  iDispense
//
//  Created by Richard Henry on 19/02/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class OrderNoteViewController: UITableViewController, UITextViewDelegate {

    // MARK: Properties

    var order: Order!

    var saveBlock: (() -> Void)?
    var cancelBlock: (() -> Void)?

    // Notes
    @IBOutlet weak var noteTextView : UITextView!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        noteTextView.text = order.comments
        noteTextView.delegate = self
        noteTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {

        super.viewWillDisappear(animated)

        order.comments = noteTextView.text

        saveBlock?()
    }

    // MARK: Text view delegate

    func textViewDidEndEditing(textView: UITextView) {

        order.comments = noteTextView.text
    }
}
