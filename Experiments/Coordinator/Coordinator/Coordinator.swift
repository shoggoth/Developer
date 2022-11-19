//
//  Coordinator.swift
//  Coordinator
//
//  Created by Richard Henry on 17/11/2022.
//  Copyright © 2022 Dogstar Industries Ltd. All rights reserved.
//

import UIKit

protocol Coordinator {
    
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
