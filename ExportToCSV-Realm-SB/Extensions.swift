//
//  Extensions.swift
//  ExportToCSV-Realm-SB
//
//  Created by Josh R on 10/5/19.
//  Copyright © 2019 Josh R. All rights reserved.
//

import Foundation
import UIKit


extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
}

extension UITableViewCell {
    class var identifier: String {
        return String(describing: self)
    }
}


//MARK: Currency Extensions
extension String {
    func cleanCurrencyFormatting() -> Double {
        var cleanedCurrencyAsString = ""
        
        for character in self {
            if character.isNumber {
                cleanedCurrencyAsString.append(character)
            }
        }
        
        let amountAsDouble = Double(cleanedCurrencyAsString) ?? 0.0
        
        return amountAsDouble / 100.0
    }
}

extension String {
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        let cleanedTextAsDouble = self.cleanCurrencyFormatting() //removes "$"
        let formatedAmount = MyFormatters.formatCurrency(for: cleanedTextAsDouble)

        return formatedAmount
    }
}


extension UIButton {
    func giveRoundCorners() {
        self.layer.cornerRadius = self.layer.frame.height / 2
    }
}


//MARK: Alert extensions -- makes life easier
extension UIViewController {
    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                completion(index)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
