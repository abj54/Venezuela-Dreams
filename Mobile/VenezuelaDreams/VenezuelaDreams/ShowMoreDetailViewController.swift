//
//  ShowMoreDetailViewController.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 4/10/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit

class ShowMoreDetailViewController: UIViewController {

    var transactionObject: TransactionObject?
    
    //outlets
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var childIDLabel: UILabel!
    
    
    @IBOutlet weak var childImage: UIImageView!
    
    @IBOutlet weak var childNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        amountLabel.text = String(describing: transactionObject?.amount)+(transactionObject?.currency)!
        currencyLabel.text = transactionObject?.currency
        statusLabel.text = transactionObject?.status
       // childIDLabel.text = transactionObject?.childID
        dateLabel.text = transactionObject?.date
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func repeatDonation(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "DonationViewController") as! DonationViewController
        myVC.childToDonateToID = transactionObject?.childID
        self.present(myVC, animated:true, completion:nil)
    }
    

}
