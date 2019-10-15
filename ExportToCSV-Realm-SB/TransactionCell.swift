//
//  TransactionCell.swift
//  ExportToCSV-Realm-SB
//
//  Created by Josh R on 10/5/19.
//  Copyright © 2019 Josh R. All rights reserved.
//

import UIKit
import RealmSwift

class TransactionCell: UITableViewCell {
    
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var payeeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configure(with transaction: Transaction) {
        payeeLbl.text = transaction.payee
        dateLbl.text = MyFormatters.format(transaction.tranDate)
        amountLbl.text = MyFormatters.formatCurrency(for: transaction.amount)
    }
}
