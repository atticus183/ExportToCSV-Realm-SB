//
//  MainTVC.swift
//  ExportToCSV-Realm-SB
//
//  Created by Josh R on 10/5/19.
//  Copyright © 2019 Josh R. All rights reserved.
//

import UIKit
import RealmSwift

class MainTVC: UITableViewController {
    
    let realm = MyRealm.getConfig()
    private var transactionsToken: NotificationToken?
    var transactions: Results<Transaction>?
    
    lazy var totalLblL: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 250, height: 30)
        label.backgroundColor = .clear
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.minimumScaleFactor = 0.6
        
        return label
    }()
    
    @IBAction func exportBtn(_ sender: UIBarButtonItem) {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Give File a Name", message: "Please enter a title for the filename.  This will export all transaction data.", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }

        // 3. Save textField contents when user presses OK and perform desired actions
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            guard let enteredFilename = textField?.text else { return }
            ExportTransactionData.createCSV(fileName: enteredFilename, in: self)
        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactions = realm?.objects(Transaction.self).sorted(byKeyPath: "tranDate", ascending: false)
        calculateTotalTransAmount()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        //this will monitor the transaction realm class and take action on updates
        transactionsToken = transactions?.observe { [ weak tableView, weak self] changes in
            guard let tableView = tableView else { return }
            switch changes {
            case .initial: break
            case .update:
                self?.calculateTotalTransAmount()
                tableView.reloadData()
            case .error: break
            }
        }
        
        self.navigationItem.titleView = totalLblL
        
        //Removes the empty cells from the tableview
        tableView.tableFooterView = UIView()
    }
    
    deinit {
        transactionsToken?.invalidate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent  //white text
    }
    
    func calculateTotalTransAmount() {
        let totalTransactionAmount = transactions?.reduce(0, { $0 + $1.amount })
        totalLblL.text = "Total: \(MyFormatters.formatCurrency(for: totalTransactionAmount ?? 0.0))"
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactions?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifier, for: indexPath) as? TransactionCell else { return UITableViewCell() }

        guard let transaction = transactions?[indexPath.row] else { return UITableViewCell() }

        cell.configure(with: transaction)
        
        return cell
    }
   
    
    //MARK: Delete transaction
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, actionPerformed: @escaping (Bool) -> ()) in
            
            let alert = UIAlertController(title: "Delete Transaction", message: "Are you sure you want to delete this Transaction?  This cannot be undone.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {   (alertAction) in
                actionPerformed(false)
            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (alertAction) in
                //Perform Delete
                guard let self = self else { return }
                guard let transaction = self.transactions?[indexPath.row] else { return }
                
                //perform expense/income delete
                do {
                    try self.realm?.write {
                        self.realm?.delete(transaction)
                    }
                } catch {
                    self.alert(message: "\(error.localizedDescription)", title: "ERROR")
                }
                //Note:  No need to perform a tableView.reload data.  The NotificationToken observes any changes to the realm
                actionPerformed(true)
            }))
            
            //Asking to confirm the delete
            self.present(alert, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

}
