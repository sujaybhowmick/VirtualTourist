//
//  ViewController+Extension.swift
//  VirtualTourist
//
//  Created by Sujay Bhowmick on 5/27/18.
//  Copyright © 2018 Sujay Bhowmick. All rights reserved.
//

import UIKit

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    func showInfo(withTitle: String = "Info", withMessage: String, action: (() -> Void)? = nil) {
        performUIUpdatesOnMain {
            let ac = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(ac, animated: true)
        }
    }
    
    func save() {
        do {
            try CoreDataStack.shared().saveContext()
        } catch {
            showInfo(withTitle: "Error", withMessage: "Error while saving Pin location: \(error)")
        }
    }
    
}
