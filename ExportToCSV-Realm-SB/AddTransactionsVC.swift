//
//  AddTransactionsVC.swift
//  ExportToCSV-Realm-SB
//
//  Created by Josh R on 10/5/19.
//  Copyright © 2019 Josh R. All rights reserved.
//

import UIKit
import RealmSwift

class AddTransactionsVC: UIViewController {
    
    let realm = MyRealm.getConfig()
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var amountTxt: UITextField!
    @IBOutlet weak var payeeTxt: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var addBtnOutlet: UIButton!
    @IBAction func addBtn(_ sender: UIButton) {
        
        guard let enteredTotalAmount = amountTxt.text else { return self.alert(message: "Please enter an amount.", title: "Enter Value")}
        
        guard let payeeName = payeeTxt.text else { return self.alert(message: "Please enter a Payee name.", title: "Enter Value")}
        
        do {
            try realm?.write {
                let transaction = Transaction()
                transaction.amount = enteredTotalAmount.cleanCurrencyFormatting()
                transaction.payee = payeeName
                transaction.tranDate = datePicker.date
                
                realm?.add(transaction)
            }
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatUIComponents()
        
        amountTxt.becomeFirstResponder()
        amountTxt.addTarget(self, action: #selector(amountTxtDidChange), for: .editingChanged)
    }
    
    @objc func amountTxtDidChange(_ textField: UITextField) {
        textField.text = amountTxt.text?.currencyInputFormatting()
        
        //Empty textfield if 0.0
        if amountTxt.text?.cleanCurrencyFormatting() == 0.0 {
            amountTxt.text = ""
        }
    }
    
    func formatUIComponents() {
        //Add Button
        addBtnOutlet.giveRoundCorners()
        
        //MainView
        mainView.layer.cornerRadius = 10
    }
    


}

