//
//  SettingsViewController.swift
//  
//
//  Created by Pascal on 4/5/18.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate{
    
    
    
    @IBOutlet weak var firstname: UILabel!
    @IBOutlet weak var textFirstName: UITextField?
    @IBOutlet weak var lastname: UILabel!
    @IBOutlet weak var textLastName: UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        textFirstName?.delegate = self
        textFirstName?.isHidden = true
        firstname.isUserInteractionEnabled = true
        let aSelector : Selector = #selector(SettingsViewController.firstnameTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        firstname.addGestureRecognizer(tapGesture)
       
    }
    
    //CHANGE FIRST NAME
    @objc func firstnameTapped(){
        firstname.isHidden = true
        textFirstName?.isHidden = false
        textFirstName?.text = firstname.text
    }
    
    
    @IBAction func userInput(sender: UITextField) {
        firstname.isHidden = true
        textFirstName?.isHidden = false
        textFirstName?.text = sender.text
    }
    

    func textFirstNameShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        textFirstName?.isHidden = true
        firstname.isHidden = false
        firstname.text = textFirstName?.text
        return true
    }
}
