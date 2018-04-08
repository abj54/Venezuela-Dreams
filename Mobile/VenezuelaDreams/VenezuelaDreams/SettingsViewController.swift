//
//  SettingsViewController.swift
//  
//
//  Created by Pascal on 4/5/18.
//  

import Foundation
import UIKit
import FirebaseAuth
import Stripe
import FirebaseDatabase

class SettingsViewController: UITableViewController, UITextFieldDelegate, STPPaymentContextDelegate {
    
    //TABLE VIEW
    @IBOutlet var tableViewSettings: UITableView!
    
    
    //BACK BUTTON
    @IBOutlet weak var backButton: UIButton!
    //FIRST NAME
    @IBOutlet weak var firstname: UILabel!
    @IBOutlet weak var textFirstName: UITextField?
    //LAST NAME
    @IBOutlet weak var lastname: UILabel!
    @IBOutlet weak var textLastName: UITextField?
    
    //EMAIL
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var textEmail: UITextField!
    
    //CONFIRM BUTTON
    @IBOutlet weak var changeContactInfo: UIButton!

    //RESET PASSWORD
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    //CHANGE PASSWORD
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordRetype: UITextField!
    @IBOutlet weak var changePassword: UIButton!

    //UPDATE PAYMENT
    
    //SIGN OUT
    @IBOutlet weak var signoutButton: UIButton!
    
    override func viewDidLoad() {
        //tableViewSettings.backgroundView = UIImageView(image: UIImage(named: "background7.png"))
        super.viewDidLoad()
        setupPaymentButton()
        GUISettings()
        getUserData()
        editorInitializer()
        
    }
    
    func GUISettings(){
        //Set password reset as security entry
        tableViewSettings.backgroundColor = UIColor.white
        currentPassword.isSecureTextEntry = true
        newPasswordRetype.isSecureTextEntry = true
        newPassword.isSecureTextEntry = true
    }
    
    func getUserID()->String{
        return (Auth.auth().currentUser!.uid)
    }
    
    //get user data for contact information
    func getUserData(){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let userID = getUserID()
        print(userID)
        ref.child("user").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            print(name)
            self.firstname.text = name
            let lastnameString = value?["lastName"] as? String
            print(lastnameString)
            self.lastname.text = lastnameString
            let emailString = value?["email"] as? String
            print(emailString)
            self.email.text = emailString
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    //Initializes editors for first name, last name, and email
    func editorInitializer(){
        editFirstNameInitializer()
        editLastNameInitializer()
        editEmailInitializer()
    }


    //BACK BUTTON
    
    @IBAction func backToMain(_ sender: Any) {
        self.performSegue(withIdentifier: "toMain", sender: self)
    }
    
    //CHANGE FIRST NAME
    
    func editFirstNameInitializer(){
        //FIRST NAME EDITOR
        //textFirstName?.delegate = self
        textFirstName?.isHidden = true
        firstname.isUserInteractionEnabled = true
        let aSelector : Selector = #selector(SettingsViewController.firstnameTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        firstname.addGestureRecognizer(tapGesture)
    }
    
    @objc func firstnameTapped(){
        firstname.isHidden = true
        textFirstName?.isHidden = false
        textFirstName?.text = firstname.text
    }
    
    @IBAction func userInputFirst(sender: UITextField) {
        firstname.isHidden = false
        textFirstName?.isHidden = true
        firstname.text = textFirstName?.text
    }
    
    //CHANGE LAST NAME
    
    func editLastNameInitializer(){
        //FIRST NAME EDITOR
        //textLastName?.delegate = self
        textLastName?.isHidden = true
        lastname.isUserInteractionEnabled = true
        let aSelector : Selector = #selector(SettingsViewController.lastnameTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        lastname.addGestureRecognizer(tapGesture)
    }
    
    @objc func lastnameTapped(){
        lastname.isHidden = true
        textLastName?.isHidden = false
        textLastName?.text = lastname.text
    }
    
    
    @IBAction func userInputLast(sender: UITextField) {
        lastname.isHidden = false
        textLastName?.isHidden = true
        lastname.text = textLastName?.text
    }
    
    //CHANGE EMAIL
    
    func editEmailInitializer(){
        //FIRST NAME EDITOR
        //textEmail?.delegate = self
        textEmail?.isHidden = true
        email.isUserInteractionEnabled = true
        let aSelector : Selector = #selector(SettingsViewController.emailTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        email.addGestureRecognizer(tapGesture)
    }
    
    @objc func emailTapped(){
        email.isHidden = true
        textEmail?.isHidden = false
        textEmail?.text = email.text
    }
    
    
    @IBAction func userInputEmail(sender: UITextField) {
        email.isHidden = false
        textEmail?.isHidden = true
        email.text = textEmail?.text
    }
    
    //CONFIRMATION BUTTON
    
    @IBAction func changeInfo(_ sender: Any) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let userID = getUserID()
        var edited = false
        if(firstname.text != ""){
            ref.child("user/\(userID)/name").setValue(textFirstName?.text)
            edited = true
        }
        if(lastname.text != ""){
            ref.child("user/\(userID)/lastName").setValue(textLastName?.text)
            edited = true
        }
        if(email.text != ""){
            ref.child("user/\(userID)/email").setValue(textEmail.text)
            edited = true
        }
        
        if(edited){
            // create the alert
            let alert = UIAlertController(title: "Contact Info Updated", message: "Your personal information has been updated.", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    

    
//CHANGE PASSWORD
    @IBAction func changePasswordPressed(_ sender: Any) {
        var user = Auth.auth().currentUser;
        var currentPassword = self.currentPassword.text
        //Catch Errors
        if(newPassword.text == ""){
            let alert = UIAlertController(title: "Reset Failed", message: "Please enter a new password", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else if(newPassword.text != newPasswordRetype.text){
            let alert = UIAlertController(title: "Reset Failed", message: "Retyped password incorrect.", preferredStyle: UIAlertControllerStyle.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
        //If Email
        let credential = EmailAuthProvider.credential(withEmail: (Auth.auth().currentUser?.email)!, password: currentPassword!)
        //If facebook
        //let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        //Authenticate if password is correct
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (error) in
            if error != nil {
                // handle error - incorrect password entered is a possibility
                return
            }
            
            // reauthentication succeeded!
            user?.updatePassword(to: self.newPassword.text!) { (errror) in
            }
        })
    }
    
    //RESET PASSWORD
    
    @IBAction func resetPassword(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: self.email.text!) { error in
            //https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift/33340757#33340757
            // create the alert
            let alert = UIAlertController(title: "Email Sent", message: "Check your email for password reset link.", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //SIGN OUT
    @IBAction func signoutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "toWelcome", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    //CHANGE PAYMENT INFORMATION
    
    @IBOutlet var inputsView: UIView!

    private let customerContext: STPCustomerContext
    private let paymentContext: STPPaymentContext
    
    required init?(coder aDecoder: NSCoder) {
        customerContext = STPCustomerContext(keyProvider: MainAPIClient.shared)
        paymentContext = STPPaymentContext(customerContext: customerContext)
        super.init(coder: aDecoder)
        
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
    
    //Setup Button
    
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
    
    func setupPaymentButton(){
        inputsView.addSubview(paymentButton)

        paymentButton.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 16).isActive = true
        paymentButton.rightAnchor.constraint(equalTo: inputsView.rightAnchor, constant: -16).isActive = true
        //paymentButton.topAnchor.constraint(equalTo: resetPasswordButton.bottomAnchor, constant: 8).isActive = true
        paymentButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        paymentButton.addTarget(self, action: #selector(self.paymentButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func paymentButtonTapped(_ sender: UIButton) {
        presentPaymentMethodsViewController()
    }
    
    // MARK: STPPaymentContextDelegate



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
        //donateButton.isEnabled = true
    }
    
    
    //Payment context
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        
        return
        /*
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
         */
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
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        self.navigationController?.popViewController(animated: true)
        print("ERROR TO USER: \(error)")
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        // Reload related components
        reloadPaymentButtonContent()
    }
    
    
    

}
