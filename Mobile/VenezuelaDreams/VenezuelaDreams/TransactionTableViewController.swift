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
    
    override func viewDidLoad() {
        getUserTransactions()
        putTransactionsintoTableView()
    }
    
    //Get user id
    func getUserID()->String{
        return (Auth.auth().currentUser!.uid)
    }
    
    //FINISH
    //Get all user transactions and put into an array
    func getUserTransactions(){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let userID = getUserID()
        print("userid is: ")
        print(userID)
        print("Transaction ids: ")
    ref.child("transactions").child("userId").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
        snapshot.children.forEach({ (child) in
            let childDict = child as? NSDictionary
            //var childID = childDict?["childID"]
            //var date = childDict?["date"]
            var amount = childDict?["amount"]
            var status = childDict?["status"]
            var currency = childDict?["currency"]
            
            //Create child object
            
            //Put child object into array
            
        })
        
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //Put transactions in the array into the tableview
    func putTransactionsintoTableView(){
        
    }
}
