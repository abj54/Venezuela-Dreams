//
//  ForgotPasswordViewController.swift
//  VenezuelaDreams
//
//  Created by Pascal on 4/8/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import Firebase

class ForgotPasswordViewController: UIViewController{
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    @IBOutlet weak var backToLoginButton: UIButton!
    
    
    @IBAction func resetPassword(_ sender: Any) {
        if((userEmailTextField.text?.count)! < 3){
            //https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift/33340757#33340757
            // create the alert
            let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address.", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }else{
            Auth.auth().sendPasswordReset(withEmail: userEmailTextField.text!) { error in
                //https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift/33340757#33340757
                // create the alert
                let alert = UIAlertController(title: "Email Sent", message: "Check your email for password reset link.", preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                self.performSegue(withIdentifier: "toLogin", sender: self)
            }
            
        }
        
    }
    
    @IBAction func backToLogin(_ sender: Any) {
        self.performSegue(withIdentifier: "toLogin", sender: self)
    }
    
    
    
    
}
