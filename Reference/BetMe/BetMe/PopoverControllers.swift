//
//  PopoverControllers.swift
//  BetMe
//
//  Created by Rich Henry on 25/04/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

class PopoverController : NSObject, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var presentingViewController: UIViewController!
    @IBOutlet weak var presentingView: UIView!

    var caching = false

    internal var popPresentCompletionBlock : ((_ vc: UIViewController) -> Void)? = nil
    internal var popDismissCompletionBlock : (() -> Void)? = nil
    internal var popShouldDismissBoolBlock : (() -> Bool) = { return true }

    internal var directions: UIPopoverArrowDirection = .any

    // Internal
    fileprivate var cache: [String:UIViewController] = [:]

    // MARK: Popup Control

    private func fetchViewControllerNamed(_ named: String) -> UIViewController? {

        // See if the VC is already in the cache
        if let vc = cache[named] { return vc }

        else {

            // Split into SB name and VC name
            let viewControllerName: String; let storyboardName: String?
            let sbPath = named.characters.split { $0 == "." }.map { String($0) }

            if sbPath.count == 1 { viewControllerName = sbPath[0]; storyboardName = nil }
            else if sbPath.count == 2 { storyboardName = sbPath[0]; viewControllerName = sbPath[1] }
            else { return nil }

            if let sb = storyboardName == nil ? presentingViewController.storyboard : UIStoryboard(name: storyboardName!, bundle: nil) {

                let vc = sb.instantiateViewController(withIdentifier: viewControllerName)

                // Cache the view controller
                if (caching) { cache[named] = vc }

                return vc
            }
        }

        return nil
    }

    func presentPopupWithViewControllerNamed(_ named: String, fromRect rect: CGRect, fromView: UIView? = nil) -> UIViewController? {

        if let viewController = self.fetchViewControllerNamed(named) {

            let view = fromView == nil ? self.presentingView : fromView

            viewController.modalPresentationStyle = .popover

            if let poc = viewController.popoverPresentationController {

                poc.sourceView = view
                poc.sourceRect = rect
                poc.permittedArrowDirections = directions

                poc.delegate = self

                DispatchQueue.main.async {

                    self.presentingViewController.present(viewController, animated: true, completion: nil)
                    self.popPresentCompletionBlock?(viewController)
                }
            }

            return viewController
        }

        return nil
    }

    // MARK: UIPopoverPresentationControllerDelegate (iOS 8)

    func popoverPresentationControllerShouldDismissPopover(_ popoverController: UIPopoverPresentationController) -> Bool { return popShouldDismissBoolBlock() }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        DispatchQueue.main.async { self.popDismissCompletionBlock?() }
    }
}
