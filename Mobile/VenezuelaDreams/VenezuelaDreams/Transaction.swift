//
//  Transaction.swift
//  VenezuelaDreams
//
//  Created by Pascal on 4/8/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import Foundation

class TransactionObject{
    var userID: String!
    var childID: String!
    var date: String?
    var amount:String?
    var status: String?
    var currency: String?
    
    init(userID: String!, childID: String!, date: String?, amount:String?, status: String?, currency: String?){
        self.userID = userID
        self.childID = childID
        self.date = date
        self.amount = amount
        self.status = status
        self.currency = currency
    }
}
