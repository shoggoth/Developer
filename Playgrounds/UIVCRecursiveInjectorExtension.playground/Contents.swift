//: Playground - noun: a place where people can play

import UIKit


extension UIViewController {

    func inject<T>(injector: (T) -> ()) {

        switch self {

        case let tabViewController as UITabBarController:

            if let viewControllers = tabViewController.viewControllers {

                for containedViewController in viewControllers { containedViewController.inject(injector: injector) }
            }

        case let navigationController as UINavigationController:

            for containedViewController in navigationController.viewControllers { containedViewController.inject(injector: injector) }

        case let inj as T:
            injector(inj)
            
        default:
            print("Doing nowt with \(self)")
        }
    }
}

public protocol UsesCoreDataStack : class {

    var coreDataStack: CoreDataStack? { get set }
}
