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

class DonationViewController: UIViewController, UITextFieldDelegate ,STPPaymentContextDelegate {

    
    private let customerContext: STPCustomerContext
    private let paymentContext: STPPaymentContext
    
    required init?(coder aDecoder: NSCoder) {
        customerContext = STPCustomerContext(keyProvider: MainAPIClient.shared)
        paymentContext = STPPaymentContext(customerContext: customerContext)
        super.init(coder: aDecoder)
        
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }

    @IBOutlet var inputsView: UIView!
    @IBOutlet weak var childToDonateView: UIView!
    var childToDonateTo : DatabaseChild?
    var childToDonateToID: String?
    var transaction_id = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpForUser()
        getChildData(childIdTransfer: childToDonateToID!)
        // Do any additional setup after loading the view.
    }
    
    func setUp(){
        let user_id = getUserId()
        print("THIS IS THE USERID: \(user_id)")
    }
    
    func setUpForUser(){
        inputsView.addSubview(paymentButton)
        paymentButton.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 16).isActive = true
        paymentButton.rightAnchor.constraint(equalTo: inputsView.rightAnchor, constant: -16).isActive = true
        paymentButton.topAnchor.constraint(equalTo: childToDonateView.bottomAnchor, constant: 8).isActive = true
        paymentButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        paymentButton.addTarget(self, action: #selector(self.paymentButtonTapped(_:)), for: .touchUpInside)
        
        inputsView.addSubview(segmentedControl)
        segmentedControl.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 16).isActive = true
        segmentedControl.rightAnchor.constraint(equalTo: inputsView.rightAnchor, constant: -16).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: paymentButton.bottomAnchor, constant: 8).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 44).isActive = true
        segmentedControl.textColor = .white
        segmentedControl.setCurrentSegmentIndex(1, animated: true)
        
        inputsView.addSubview(amountTextField)
        amountTextField.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 16).isActive = true
        amountTextField.rightAnchor.constraint(equalTo: inputsView.rightAnchor, constant: -16).isActive = true
        amountTextField.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8).isActive = true
        amountTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)

        inputsView.addSubview(donateButton)
        donateButton.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 16).isActive = true
        donateButton.rightAnchor.constraint(equalTo: inputsView.rightAnchor, constant: -16).isActive = true
        donateButton.bottomAnchor.constraint(equalTo: inputsView.bottomAnchor, constant: -8).isActive = true
        donateButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        donateButton.addTarget(self, action: #selector(self.donateButtonTapped(_:)), for: .touchUpInside)
        paymentButton.layoutIfNeeded()

    }

    @objc func paymentButtonTapped(_ sender: UIButton) {
        presentPaymentMethodsViewController()
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
            segmentedControl.setCurrentSegmentIndex(5, animated: true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        segmentedControl.setCurrentSegmentIndex(5, animated: true)
    }

    private func presentPaymentMethodsViewController() {
        guard !STPPaymentConfiguration.shared().publishableKey.isEmpty else {
            // Present error immediately because publishable key needs to be set
            let message = "Please assign a value to `publishableKey` before continuing. See `AppDelegate.swift`."
            print(message)
            //present(UIAlertController(message: message), animated: true)
            return
        }
        
        guard !MainAPIClient.shared.baseURLString.isEmpty else {
            // Present error immediately because base url needs to be set
            let message = "Please assign a value to `MainAPIClient.shared.baseURLString` before continuing. See `AppDelegate.swift`."
            print(message)
            //present(UIAlertController(message: message), animated: true)
            return
        }
        
        // Present the Stripe payment methods view controller to enter payment details
        paymentContext.presentPaymentMethodsViewController()
    }
    
    private func reloadPaymentButtonContent() {
        guard let selectedPaymentMethod = paymentContext.selectedPaymentMethod else {
            // Show default image, text, and color
            paymentButton.setImage(#imageLiteral(resourceName: "Payment"), for: .normal)
            paymentButton.setTitle("  Payment", for: .normal)
            paymentButton.setTitleColor(UIColor(red: 50.0 / 255.0, green: 49.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0), for: .normal)
            return
        }
                // #0090FA
        // Show selected payment method image, label, and darker color
        let img = selectedPaymentMethod.image
        let text = selectedPaymentMethod.label
        
        print("This is the button:: \(text)")
        paymentButton.setImage(img, for: .normal)
        paymentButton.setTitle("  \(text)", for: .normal)
        paymentButton.setTitleColor(UIColor(red: 0.0 / 255.0, green: 144.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0), for: .normal)
        donateButton.isEnabled = true
    }
    
    // MARK: STPPaymentContextDelegate
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        self.navigationController?.popViewController(animated: true)
        print("ERROR TO USER: \(error)")
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        // Reload related components
        reloadPaymentButtonContent()
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        // Create charge using payment result
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
        } else if (index == 4){
            amount = "5000"
        } else {
            var text = amountTextField.text!
            let index_$ = text.index(of: "$")
            text.remove(at: index_$!)
            let index_dot = text.index(of: ".")
            text.remove(at: index_dot!)
            if (text.contains(",")){
                let index_comma = text.index(of: ",")
                text.remove(at: index_comma!)
            }
            amount = text
            print("THIS IS THE AMOUNT: \(amount)")
        }
        
        let source = paymentResult.source.stripeID
        sendToken(source: source, amount: amount)
        //sendChildId()
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        switch status {
        case .error:
            print(error!)
        case .success:
            print("Succeded! PAYMENT WORKED!")
        case .userCancellation:
            return // Do nothing
        }
    }

    @objc func donateButtonTapped(_ sender: AnyObject?) {
        
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
        paymentContext.paymentAmount = Int(amount)!
        paymentContext.requestPayment()
    }

    func sendToken(source: String, amount: String){
        let ref = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        let userId = Auth.auth().currentUser!.uid
    
        let values = ["amount": amount, "source": source, "child_id": childToDonateToID]
        ///transactions/userId/{userId}/transactionId/{transactionId}
        let usersReference = ref.child("transactions").child("userId").child(userId).child("transactionId").childByAutoId()
        transaction_id = usersReference.key
        usersReference.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
            if (err != nil){
                print(err ?? "ERROR!!")
                return
            }
            print("Saved token succesfnully")
        })
    }
    
    func sendChildId(){
        let ref = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        let userId = Auth.auth().currentUser!.uid
        
        let values = ["child_id": childToDonateToID]
        ///transactions/userId/{userId}/transactionId/{transactionId}
        let usersReference = ref.child("transactions").child("userId").child(userId).child("transactionId").child(self.transaction_id)
        usersReference.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
            if (err != nil){
                print(err ?? "ERROR!!")
                return
            }
            print("Saved child_id succesfnully")
        })
    }
    
    func getUserId() -> String{
        return (Auth.auth().currentUser!.uid)
    }
    
    func getChildData(childIdTransfer: String){
        var refChild: DatabaseReference!
        var childFromDatabase: DatabaseChild?
        refChild = Database.database().reference(withPath: "child").child(childIdTransfer)
        refChild.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let childName = value?["first_name"]
            let childDescription = value?["description"]
            let childID = refChild.key
            let imageUrl = value?["imageurl"]
            childFromDatabase = DatabaseChild(id: childID, name: childName as? String, description: childDescription as? String, childUrl: imageUrl  as? String)
            self.childToDonateTo = childFromDatabase
            self.loadChild()
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //Load child to donate
    func loadChild(){
        let card = CardArticle(frame: CGRect(x: 10, y: 30, width: self.paymentButton.bounds.width , height: self.childToDonateView.bounds.height))
        card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
        card.category = (childToDonateTo?.name)!
        card.categoryLbl.textColor = UIColor.white
        card.title = ""
        card.subtitle = (childToDonateTo?.description)!
        card.blurEffect = .light
        card.textColor = UIColor.white
        card.hasParallax = true
        //SET IMAGE
        let imageUrlString = childToDonateTo?.childUrl
        //let imageUrl:URL = URL(string: imageUrlString!)!
        
        // Start background thread so that image loading does not make app unresponsive
        //        DispatchQueue.global(qos: .userInitiated).async {
        //
        //            let imageData:NSData = NSData(contentsOf: imageUrl)!
        //            let imageView = UIImageView(frame: CGRect(x:0, y:0, width:200, height:200))
        //            imageView.center = self.view.center
        //
        //            // When from background thread, UI needs to be updated on main_queue
        //            DispatchQueue.main.async {
        //                let image = UIImage(data: imageData as Data)
        //                card.backgroundImage = image
        //            }
        //        }
        

        let cardContentVC = storyboard!.instantiateViewController(withIdentifier: "CardContent")
        card.shouldPresent(cardContentVC, from: self, fullscreen: false)
        
        //set origin of x coordinate for the card
        card.frame.origin.x = (self.view.bounds.width - self.paymentButton.bounds.width) / 2
        //set origin of the y coordinate for the card
        card.frame.origin.y = 0
        childToDonateView.addSubview(card)
    }
    
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
        sc.textColor = UIColor.lightText
        sc.backgroundColor = UIColor(red:66.0/255.0, green:69.0/255.0, blue:112.0/255.0, alpha:255.0/255.0)//#colorLiteral(red: 0, green: 0.2705698013, blue: 0.3583087921, alpha: 1)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    let amountTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Amount: $0.00", attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightText])
        tf.textColor = UIColor.white
        tf.backgroundColor = UIColor(red:66.0/255.0, green:69.0/255.0, blue:112.0/255.0, alpha:255.0/255.0)
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5
        tf.layer.borderColor = UIColor(red:14.0/255.0, green:211.0/255.0, blue:140.0/255.0, alpha:255.0/255.0).cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clipsToBounds = true
        tf.keyboardType = .decimalPad
        tf.textAlignment = .center
        return tf
    }()
    
    let paymentButton: UIButton = {
        let tf = UIButton()
        tf.backgroundColor = UIColor(red:66.0/255.0, green:69.0/255.0, blue:112.0/255.0, alpha:255.0/255.0)
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5
        tf.layer.borderColor = UIColor(red:14.0/255.0, green:211.0/255.0, blue:140.0/255.0, alpha:255.0/255.0).cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clipsToBounds = true
        tf.setTitle("  Payment", for: .normal)
        tf.setImage(#imageLiteral(resourceName: "Payment"), for: .normal)
        return tf
    }()
    
    let donateButton: UIButton = {
        let tf = UIButton()
        tf.backgroundColor = UIColor(red:66.0/255.0, green:69.0/255.0, blue:112.0/255.0, alpha:255.0/255.0)
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5
        tf.layer.borderColor = UIColor(red:14.0/255.0, green:211.0/255.0, blue:140.0/255.0, alpha:255.0/255.0).cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clipsToBounds = true
        //tf.backgroundColor = #colorLiteral(red: 0.1149113253, green: 0.3041413426, blue: 0.4084678888, alpha: 1)
        tf.setTitle("Donate", for: .normal)
        tf.isEnabled = false
        return tf
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DonationViewController: SJFluidSegmentedControlDataSource {
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 6
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
        } else if index == 4 {
            return "$50.00"
        } else {
            return "Other"
        }
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForSelectedSegmentAtIndex index: Int) -> [UIColor] {
        switch index {
        case 0:
            amountTextField.text = ""
            return [UIColor(red: 51 / 255.0, green: 149 / 255.0, blue: 182 / 255.0, alpha: 1.0),
                    UIColor(red: 97 / 255.0, green: 199 / 255.0, blue: 234 / 255.0, alpha: 1.0)]
        case 1:
            amountTextField.text = ""
            return [UIColor(red: 227 / 255.0, green: 206 / 255.0, blue: 160 / 255.0, alpha: 1.0),
                    UIColor(red: 225 / 255.0, green: 195 / 255.0, blue: 128 / 255.0, alpha: 1.0)]
        case 2:
            amountTextField.text = ""
            return [UIColor(red: 21 / 255.0, green: 94 / 255.0, blue: 119 / 255.0, alpha: 1.0),
                    UIColor(red: 9 / 255.0, green: 82 / 255.0, blue: 107 / 255.0, alpha: 1.0)]
        case 3:
            amountTextField.text = ""
            return [UIColor(red: 51 / 255.0, green: 149 / 255.0, blue: 182 / 255.0, alpha: 1.0),
                    UIColor(red: 97 / 255.0, green: 199 / 255.0, blue: 234 / 255.0, alpha: 1.0)]
        case 4:
            amountTextField.text = ""
            return [UIColor(red: 227 / 255.0, green: 206 / 255.0, blue: 160 / 255.0, alpha: 1.0),
                    UIColor(red: 225 / 255.0, green: 195 / 255.0, blue: 128 / 255.0, alpha: 1.0)]
        case 5:
            return [UIColor(red: 51 / 255.0, green: 149 / 255.0, blue: 182 / 255.0, alpha: 1.0),
                    UIColor(red: 97 / 255.0, green: 199 / 255.0, blue: 234 / 255.0, alpha: 1.0)]
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

extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
}
