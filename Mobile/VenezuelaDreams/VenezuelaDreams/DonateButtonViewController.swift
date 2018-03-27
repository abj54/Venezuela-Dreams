//
//  DonateButtonViewController.swift
//  VenezuelaDreams
//
//  Created by Pascal on 3/12/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit

class DonateButtonViewController: UIViewController {

    var transferChildID: String? 
    
    @IBOutlet weak var donateButton: DonateButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    @IBAction func goToDonationPage(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "DonationViewController") as! DonationViewController
        print("Transfer Child ID:")
        print(transferChildID as? String)
        myVC.childToDonateToID = transferChildID!
        self.present(myVC, animated:true, completion:nil)
    }
    
}
