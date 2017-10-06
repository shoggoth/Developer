//
//  NoteTextView.swift
//  iDispense
//
//  Created by Richard Henry on 06/05/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class NoteTextView: UIView, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var notePlaceHolderLabel : UILabel!

    var endEditingBlock: ((_ text: String) -> Void)?
    var text: String {

        get { return textView.text }
        set { textView.text = newValue; notePlaceHolderLabel.isHidden = textView.hasText }
    }

    // MARK: Setup

    override func awakeFromNib() {

        textView.delegate = self
    }

    // MARK: Text view delegate

    func textViewDidChange(_ textView: UITextView) {

        notePlaceHolderLabel.isHidden = textView.hasText
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        endEditingBlock?(self.textView.text)
    }
}
