//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

let container = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))

let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
view.backgroundColor = UIColor.green
container.addSubview(view)

UIView.animate(withDuration: 5) { view.center = CGPoint(x: 75.0, y: 75.0) }

XCPlaygroundPage.currentPage.liveView = container
