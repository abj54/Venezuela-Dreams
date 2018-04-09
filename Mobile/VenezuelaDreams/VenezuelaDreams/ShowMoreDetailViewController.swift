//
//  ShowMoreDetailViewController.swift
//  
//
//  Created by Pascal on 4/9/18.
//

import UIKit
import Firebase

class ShowMoreDetailViewController: UIViewController {
    //object from table
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
        amountLabel.text = String(describing: transactionObject?.amount)
        currencyLabel.text = transactionObject?.currency
        statusLabel.text = transactionObject?.status
        childIDLabel.text = transactionObject?.childID
        dateLabel.text = transactionObject?.date
        
        //Get child Data
        var refChild: DatabaseReference!
        refChild = Database.database().reference().child("child").child((transactionObject?.childID)!)
        refChild.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let childObject = snapshot.value as? NSDictionary
            let childName = (childObject?["first_name"] as! String) + " " + (childObject?["last_name"] as! String)
            self.childNameLabel.text = childName
            
            let imageUrlString1 = childObject?["img_url"]
            
            
            //SET IMAGEas
            //GET IMAGE
            // http://swiftdeveloperblog.com/code-examples/uiimageview-and-uiimage-load-image-from-remote-url/
            let imageUrlString = imageUrlString1
            let imageUrl:URL = URL(string: imageUrlString! as! String)!
            // Start background thread so that image loading does not make app unresponsive
            DispatchQueue.global(qos: .userInitiated).async {
                if let url:URL = URL(string: imageUrlString! as! String), let data:NSData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        let image = UIImage(data: data as Data)
                        self.childImage.image = image
                    }
                } else {
                    //If image cannot be retreived, use default image
                    print("something went wrong")
                    self.childImage.image = UIImage(named: "unknownperson")
                }
            }
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
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
