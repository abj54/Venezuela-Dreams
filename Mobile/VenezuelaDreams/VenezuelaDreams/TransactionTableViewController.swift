//
//  TransactionTableViewController.swift
//  VenezuelaDreams
//
//  Created by Pascal on 4/8/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import Firebase

class TransactionTableViewController: UITableViewController{
    
    var user_transactions = [TransactionObject]()
    
    override func viewWillAppear(_ animated: Bool) {
              // navigationItem.title = "Back"
           // navigationItem.backBarButtonItem =
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userID = getUserID()
        var ref: DatabaseReference!
        ref = Database.database().reference().child("transactions").child("userId").child(userID).child("transactionId")
        ref.observe(DataEventType.value, with: { (snapshot) in
            
            //if the reference have some values
            if snapshot.childrenCount > 0 {
                
                //clearing the list
                self.user_transactions.removeAll()
                
                //iterating through all the values
                for transactions in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let childDict = transactions.value as? [String: AnyObject]
                    //no error get transaction
                    let error = childDict?["error"] as? String
                    if(error == nil){
                        //get transaction data
                        let childid = childDict!["child_id"] as? String
                        print(childid)
                        let transdate = childDict?["transaction_date"] as? String
                        print(transdate)
                        let transamount = childDict?["amount"] as? Int
                        print(transamount)
                        let transcurrency = "usd"
                        let transstatus = "complete"

                        /*
                        let childid = "-L8eS1boSGS_zZCg5oth"
                        let transamount = 500
                        let transdate = "4/5/7"
                        */
                        //Create child object
                        let transaction = TransactionObject(userID: self.getUserID(), childID: childid as! String, date: transdate as! String, amount: transamount as! Int,status: transstatus as! String, currency: transcurrency as! String)
                        //Add it to database

                        self.user_transactions.append(transaction)
                    }
                }
                
                //reloading the tableview
                self.tableView.reloadData()
            }
        })
    }
    
    //Get user id
    func getUserID()->String{
        return (Auth.auth().currentUser!.uid)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //DISPLAY THE DATA
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user_transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TransactionCell"
        print("ADDING CELL")
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TransactionCell
            else {
            fatalError("The dequeued cell is not an instance of TransactionCell.")
        }
        

        // Configure the cell...
        let transaction = user_transactions[indexPath.row]
        
        cell.amountLabel.text = String(describing: transaction.amount!)
        cell.dateLabel.text = transaction.date!
        cell.transactionObject = transaction
        return cell
    }
    
    

    //NAVIAGATION
    let blogSegueIdentifier = "showDetail"
    
    // method to run when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "showDetail",
            let destination = segue.destination as? ShowMoreDetailViewController,
            var transIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.transactionObject = user_transactions[transIndex]
        }
    }
    
    

}
