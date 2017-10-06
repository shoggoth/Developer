//
//  Error.swift
//  BetMe
//
//  Created by Rich Henry on 16/08/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

func reportError(fromViewController viewController: UIViewController? = nil, withTitle title: String? = nil, message: String? = nil, code: String? = nil) {

    let errorTitle = title ?? "Error"
    let errorMessage = message ?? "Unknown Error"
    let errorCode = code ?? ""

    if let vc = viewController {

        let alertController = UIAlertController(title: errorTitle, message: "\(errorMessage).\n\(errorCode)", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        vc.present(alertController, animated: true)

    } else { print("Error : \(errorTitle) \(errorMessage) \(errorCode)") }
}

func checkAndReportError(fromDictionary dict: [String : Any]?, fromViewController viewController: UIViewController? = nil, withTitle title: String? = nil) -> Bool {

    if let error = dict?["error"] as? [String : Any] {

        reportError(fromViewController: viewController, withTitle: title, message: error["message"] as? String, code: error["code"] as? String)

        // The check failed, there was an error (and it was reported).
        return false
    }

    // The check succeeded, no error code was found in the dictionary.
    return true
}

func stripResultOrReportError(fromDictionary dict: [String : Any]?, fromViewController viewController: UIViewController? = nil, withTitle title: String? = "Error") -> Any? {

    return checkAndReportError(fromDictionary: dict, fromViewController: viewController, withTitle: title) ? dict?["result"] : nil
}
