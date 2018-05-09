//
//  UIStoryboard.swift
//  Project
//
//  Created by Benjamin Bourasseau on 2017-05-05.
//  Copyright © 2017 Guaraná Technologies Inc. All rights reserved.
//

import Foundation

extension UIStoryboard {
    func instantiateViewController(withRoute route: Route) -> UIViewController {
        return self.instantiateViewController(withIdentifier: route.identifier)
    }
}
