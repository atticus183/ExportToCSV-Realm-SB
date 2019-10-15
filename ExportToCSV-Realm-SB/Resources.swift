//
//  Resources.swift
//  ExportToCSV-Realm-SB
//
//  Created by Josh R on 10/5/19.
//  Copyright © 2019 Josh R. All rights reserved.
//

import Foundation
import RealmSwift

struct MyFormatters {
    static func format(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = .current
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium
        
        return dateFormatter.string(from: date)
    }
    
    static func formatDateForExport(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = .current
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        
        return dateFormatter.string(from: date)
    }
    
    static func formatCurrency(for money: Double) -> String {
        let convertedAmount = money as NSNumber
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        
        return numberFormatter.string(from: convertedAmount) ?? ""
    }
}

//MARK: CSV Exporter function
struct ExportTransactionData {
    static func createCSV(fileName: String, in vc: UIViewController) -> Void {
        let realm = MyRealm.getConfig()
        
        //Retrieve all transactions
        guard let allTransactions = realm?.objects(Transaction.self) else { return }
        
        //Create full filename
        let fullFileName = getDocumentsDirectory().appendingPathComponent("\(fileName).csv")
        
        //Column headers
        var csvOutputText = "Payee, Amount, Date\n"
        
        //Loop through all transactions and extract data
        for transaction in allTransactions {
            var newLine = ""
            newLine.append("\(String(describing: transaction.payee)),")
            newLine.append("\(String(describing: transaction.amount)),")
            newLine.append("\(MyFormatters.formatDateForExport(transaction.tranDate)),")
            newLine.append("\n")  //always be last, this starts a new line
            
            csvOutputText.append(newLine)
        }
        
        do {
            try csvOutputText.write(to: fullFileName, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            vc.alert(message: "\(error.localizedDescription)", title: "ERROR")
        }
        
        let activity = UIActivityViewController(activityItems: [fullFileName], applicationActivities: nil)
        vc.present(activity, animated: true)
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths[0])
        return paths[0]
    }
}



