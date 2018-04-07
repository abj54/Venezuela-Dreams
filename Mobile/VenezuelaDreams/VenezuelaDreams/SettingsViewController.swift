//
//  SettingsViewController.swift
//  
//
//  Created by Pascal on 4/5/18.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
class SettingsViewController: UITableViewController, UITextFieldDelegate{
    
    func getUserID()->String{
        return (FIRAuth.auth()!.currentUser!.uid)
    }
    
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
    @IBOutlet weak var updatePaymentButton: UIButton!
    
    //SIGN OUT
    @IBOutlet weak var signoutButton: UIButton!
    
    override func viewDidLoad() {
        //tableViewSettings.backgroundView = UIImageView(image: UIImage(named: "background7.png"))
        tableViewSettings.backgroundColor = UIColor.white
        super.viewDidLoad()
        
        GUISettings()
        getUserData()
        editorInitializer()
        
    }
    

    func GUISettings(){
        //Set password reset as security entry
        currentPassword.isSecureTextEntry = true
        newPasswordRetype.isSecureTextEntry = true
        newPassword.isSecureTextEntry = true
        

        
    }
    
    //get user data for contact information
    func getUserData(){
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
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
        textFirstName?.delegate = self
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
        textLastName?.delegate = self
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
        textEmail?.delegate = self
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
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
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
        var user = FIRAuth.auth()?.currentUser;
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
        let credential = FIREmailPasswordAuthProvider.credential(withEmail: (FIRAuth.auth()?.currentUser?.email)!, password: currentPassword!)
        //If facebook
        //let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        //Authenticate if password is correct
        FIRAuth.auth()?.currentUser?.reauthenticate(with: credential, completion: { (error) in
            if error != nil {
                // handle error - incorrect password entered is a possibility
                return
            }
            
            // reauthentication succeeded!
            user?.updatePassword(self.newPassword.text!) { (errror) in
            }
        })
        
        
    }
    
    //RESET PASSWORD
    
    @IBAction func resetPassword(_ sender: Any) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: self.email.text!) { error in
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
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            self.performSegue(withIdentifier: "toWelcome", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    

}
