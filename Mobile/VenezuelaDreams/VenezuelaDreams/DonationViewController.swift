//
//  DonationViewController.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 3/8/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit
import Firebase
import Stripe

class DonationViewController: UIViewController, STPPaymentCardTextFieldDelegate {

    @IBOutlet var inputsView: UIView!
    @IBOutlet weak var childToDonateView: UIView!
    @IBOutlet weak var donateButton: UIButton!
    var paymentTextField = STPPaymentCardTextField()
    //Child to donate to
    var childToDonateTo : DatabaseChild?
    var childToDonateToID: String?
    //var theme = STPTheme.default()

    let theme: STPTheme = {
        let th = STPTheme.default()
        th.primaryBackgroundColor = UIColor(red:66.0/255.0, green:69.0/255.0, blue:112.0/255.0, alpha:255.0/255.0)
        th.secondaryBackgroundColor = th.primaryBackgroundColor
        th.primaryForegroundColor = UIColor.white
        th.secondaryForegroundColor = UIColor(red:130.0/255.0, green:147.0/255.0, blue:168.0/255.0, alpha:255.0/255.0)
        th.accentColor = UIColor(red:14.0/255.0, green:211.0/255.0, blue:140.0/255.0, alpha:255.0/255.0)
        th.errorColor = UIColor(red:237.0/255.0, green:83.0/255.0, blue:69.0/255.0, alpha:255.0/255.0)
    return th
    }()
    // Define a lazy var
    lazy var segmentedControl: SJFluidSegmentedControl = {
        
        // Setup the frame per your needs
        let sc = SJFluidSegmentedControl(frame: CGRect(x: 0, y: 0, width: donateButton.frame.width, height: donateButton.frame.height))
        sc.cornerRadius = 25
        sc.dataSource = self
        sc.backgroundColor = #colorLiteral(red: 0, green: 0.2705698013, blue: 0.3583087921, alpha: 1)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
        }()
    
    
    func getChildData(childIdTransfer: String){
        var refChild: FIRDatabaseReference!
        var childFromDatabase: DatabaseChild?
        refChild = FIRDatabase.database().reference(withPath: "child").child(childIdTransfer)
        refChild.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let childName = value?["first_name"]
            let childDescription = value?["description"]
            let childID = refChild.key as! String
            let imageUrl = value?["imageurl"]
            childFromDatabase = DatabaseChild(id: childID, name: childName as! String, description: childDescription as? String, childUrl: imageUrl  as? String)
            self.childToDonateTo = childFromDatabase
            self.loadChild()
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Child to donate to ID:")
        print(childToDonateToID)
        getChildData(childIdTransfer: childToDonateToID!)
        setUp()
        // Do any additional setup after loading the view.
    }
    
    func setUp(){
        //loadChild()
        
        donateButton.backgroundColor = #colorLiteral(red: 0.1149113253, green: 0.3041413426, blue: 0.4084678888, alpha: 1)
        donateButton.setTitle("Donate", for: .normal)
        donateButton.layer.cornerRadius = 25

        //inputsView.backgroundColor = #colorLiteral(red: 0.1149113253, green: 0.3041413426, blue: 0.4084678888, alpha: 1)
        //childToDonateView.backgroundColor = #colorLiteral(red: 0.1149113253, green: 0.3041413426, blue: 0.4084678888, alpha: 1)
        
        paymentTextField.delegate = self
        paymentTextField.backgroundColor = theme.secondaryBackgroundColor
        paymentTextField.textColor = theme.primaryForegroundColor
        paymentTextField.placeholderColor = theme.secondaryForegroundColor
        paymentTextField.borderColor = theme.accentColor
        paymentTextField.borderWidth = 1.0
        paymentTextField.textErrorColor = theme.errorColor
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paymentTextField)
        paymentTextField.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 16).isActive = true
        paymentTextField.rightAnchor.constraint(equalTo: inputsView.rightAnchor, constant: -16).isActive = true
        paymentTextField.topAnchor.constraint(equalTo: childToDonateView.bottomAnchor, constant: 16).isActive = true
    
        donateButton.isEnabled = false
        donateButton.addTarget(self, action: #selector(self.submitCard(_:)), for: .touchUpInside)
        
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        
        inputsView.addSubview(segmentedControl)
        segmentedControl.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 16).isActive = true
        segmentedControl.rightAnchor.constraint(equalTo: inputsView.rightAnchor, constant: -16).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: paymentTextField.bottomAnchor, constant: 8).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 44).isActive = true

    }

    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        donateButton.isEnabled = textField.isValid
    }
    
    @IBAction func submitCard(_ sender: AnyObject?) {
        // If you have your own form for getting credit card information, you can construct
        // your own STPCardParams from number, month, year, and CVV.
        let cardParams = paymentTextField.cardParams
        
        STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
            guard let stripeToken = token else {
                NSLog("Error creating token: %@", error!.localizedDescription);
                return
            }
            
            // TODO: send the token to your server so it can create a charge
            let index = self.segmentedControl.currentSegment
            var amount = ""
            if (index == 0){
                amount = "200"
            } else if (index == 1){
                amount = "500"
            } else if (index == 2){
                amount = "1000"
            } else if (index == 3){
                amount = "2000"
            } else {
                amount = "5000"
            }
            self.sendToken(token: token!, amount: amount)
            let alert = UIAlertController(title: "Welcome to Stripe", message: "Token created: \(stripeToken)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func sendToken(token: STPToken, amount: String){
        let ref = FIRDatabase.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        let userId = FIRAuth.auth()?.currentUser!.uid
    
        let values = ["amount": amount, "token": String(describing: token)]
        ///transactions/userId/{userId}/transactionId/{transactionId}
        let usersReference = ref.child("transactions").child("userId").child(userId!).child("transactionId").childByAutoId()
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if (err != nil){
                print(err ?? "")
                return
            }
            print("Saved user succesfully into db")
        })
    }
    
    //Load child to donate
    func loadChild(){
        let card = CardArticle(frame: CGRect(x: 10, y: 30, width: self.donateButton.bounds.width , height: self.childToDonateView.bounds.height))
        card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
        card.category = (childToDonateTo?.name)!
        card.categoryLbl.textColor = UIColor.white
        card.title = ""
        card.subtitle = (childToDonateTo?.description)!
        card.blurEffect = .light
        //SET IMAGE
        let imageUrlString = childToDonateTo?.childUrl
        let imageUrl:URL = URL(string: imageUrlString!)!
        
        // Start background thread so that image loading does not make app unresponsive
        DispatchQueue.global(qos: .userInitiated).async {
            
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            let imageView = UIImageView(frame: CGRect(x:0, y:0, width:200, height:200))
            imageView.center = self.view.center
            
            // When from background thread, UI needs to be updated on main_queue
            DispatchQueue.main.async {
                let image = UIImage(data: imageData as Data)
                card.backgroundImage = image
            }
        }
        
        card.textColor = UIColor.white
        card.hasParallax = true
        let cardContentVC = storyboard!.instantiateViewController(withIdentifier: "CardContent")
        card.shouldPresent(cardContentVC, from: self, fullscreen: false)

        childToDonateView.addSubview(card)

        //set origin of x coordinate for the card
        card.frame.origin.x = (self.view.bounds.width - self.donateButton.bounds.width) / 2

        //set origin of the y coordinate for the card
        card.frame.origin.y = 0
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DonationViewController: SJFluidSegmentedControlDataSource {
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 5
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          titleForSegmentAtIndex index: Int) -> String? {
        if index == 0 {
            return "$2.00"
        } else if index == 1 {
            return "$5.00"
        } else if index == 2 {
            return "$10.00"
        } else if index == 3 {
            return "$20.00"
        }
        return "$50.00"
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForSelectedSegmentAtIndex index: Int) -> [UIColor] {
        switch index {
        case 0:
            return [UIColor(red: 51 / 255.0, green: 149 / 255.0, blue: 182 / 255.0, alpha: 1.0),
                    UIColor(red: 97 / 255.0, green: 199 / 255.0, blue: 234 / 255.0, alpha: 1.0)]
        case 1:
            return [UIColor(red: 227 / 255.0, green: 206 / 255.0, blue: 160 / 255.0, alpha: 1.0),
                    UIColor(red: 225 / 255.0, green: 195 / 255.0, blue: 128 / 255.0, alpha: 1.0)]
        case 2:
            return [UIColor(red: 21 / 255.0, green: 94 / 255.0, blue: 119 / 255.0, alpha: 1.0),
                    UIColor(red: 9 / 255.0, green: 82 / 255.0, blue: 107 / 255.0, alpha: 1.0)]
        case 3:
            return [UIColor(red: 51 / 255.0, green: 149 / 255.0, blue: 182 / 255.0, alpha: 1.0),
                    UIColor(red: 97 / 255.0, green: 199 / 255.0, blue: 234 / 255.0, alpha: 1.0)]
        case 4:
            return [UIColor(red: 227 / 255.0, green: 206 / 255.0, blue: 160 / 255.0, alpha: 1.0),
                    UIColor(red: 225 / 255.0, green: 195 / 255.0, blue: 128 / 255.0, alpha: 1.0)]
        default:
            break
        }
        return [.clear]
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForBounce bounce: SJFluidSegmentedControlBounce) -> [UIColor] {
        switch bounce {
        case .left:
            return [UIColor(red: 51 / 255.0, green: 149 / 255.0, blue: 182 / 255.0, alpha: 1.0)]
        case .right:
            return [UIColor(red: 9 / 255.0, green: 82 / 255.0, blue: 107 / 255.0, alpha: 1.0)]
        }
    }
}
