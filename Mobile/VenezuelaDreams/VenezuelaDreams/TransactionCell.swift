//
//  TransactionCell.swift
//  VenezuelaDreams
//
//  Created by Pascal on 4/9/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class TransactionCell: UITableViewCell{
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    var transactionObject: TransactionObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    

    
}

