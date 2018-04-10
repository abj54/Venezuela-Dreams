//
//  AdminViewController.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 3/27/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit
import Firebase

class AdminViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        // Do any additional setup after loading the view.
    }
    
    func setUp(){
        view.addSubview(addChildButton)
        addChildButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addChildButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height/3).isActive = true
        addChildButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        addChildButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        addChildButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(removeChildButton)
        removeChildButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        removeChildButton.topAnchor.constraint(equalTo: addChildButton.bottomAnchor, constant: 15).isActive = true
        removeChildButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        removeChildButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        removeChildButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(editChildButton)
        editChildButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        editChildButton.topAnchor.constraint(equalTo: removeChildButton.bottomAnchor, constant: 15).isActive = true
        editChildButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        editChildButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        editChildButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(proofButton)
        proofButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        proofButton.topAnchor.constraint(equalTo: editChildButton.bottomAnchor, constant: 15).isActive = true
        proofButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        proofButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        proofButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(logoutButton)
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutButton.topAnchor.constraint(equalTo: proofButton.bottomAnchor, constant: 15).isActive = true
        logoutButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        logoutButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addChildButton.addTarget(self, action: #selector(self.addChildSegue(_:)), for: .touchUpInside)
        removeChildButton.addTarget(self, action: #selector(self.removeChildSegue(_:)), for: .touchUpInside)
        editChildButton.addTarget(self, action: #selector(self.editChildSegue(_:)), for: .touchUpInside)
        proofButton.addTarget(self, action: #selector(self.proofSegue(_:)), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(self.logoutTapped(_:)), for: .touchUpInside)
    }
    
    let addChildButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Add Child", for: .normal)
        bt.setTitleColor(UIColor.white, for: .normal)
        bt.backgroundColor = UIColor(red:66.0/255.0, green:69.0/255.0, blue:112.0/255.0, alpha:255.0/255.0)
        bt.layer.borderWidth = 1.0
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor(red:14.0/255.0, green:211.0/255.0, blue:140.0/255.0, alpha:255.0/255.0).cgColor
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.clipsToBounds = true
        return bt
    }()
    
    let removeChildButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Remove Child", for: .normal)
        bt.setTitleColor(UIColor.white, for: .normal)
        bt.backgroundColor = UIColor(red:66.0/255.0, green:69.0/255.0, blue:112.0/255.0, alpha:255.0/255.0)
        bt.layer.borderWidth = 1.0
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor(red:14.0/255.0, green:211.0/255.0, blue:140.0/255.0, alpha:255.0/255.0).cgColor
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.clipsToBounds = true
        return bt
    }()
    
    let editChildButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Edit Child", for: .normal)
        bt.setTitleColor(UIColor.white, for: .normal)
        bt.backgroundColor = UIColor(red:66.0/255.0, green:69.0/255.0, blue:112.0/255.0, alpha:255.0/255.0)
        bt.layer.borderWidth = 1.0
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor(red:14.0/255.0, green:211.0/255.0, blue:140.0/255.0, alpha:255.0/255.0).cgColor
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.clipsToBounds = true
        return bt
    }()
    
    let proofButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Add Proof", for: .normal)
        bt.setTitleColor(UIColor.white, for: .normal)
        bt.backgroundColor = UIColor(red:66.0/255.0, green:69.0/255.0, blue:112.0/255.0, alpha:255.0/255.0)
        bt.layer.borderWidth = 1.0
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor(red:14.0/255.0, green:211.0/255.0, blue:140.0/255.0, alpha:255.0/255.0).cgColor
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.clipsToBounds = true
        return bt
    }()
    
    let logoutButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Logout", for: .normal)
        bt.setTitleColor(UIColor.white, for: .normal)
        bt.backgroundColor = UIColor(red:66.0/255.0, green:69.0/255.0, blue:112.0/255.0, alpha:255.0/255.0)
        bt.layer.borderWidth = 1.0
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor(red:14.0/255.0, green:211.0/255.0, blue:140.0/255.0, alpha:255.0/255.0).cgColor
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.clipsToBounds = true
        return bt
    }()
    
    @objc func addChildSegue(_ sender : UIButton){
        self.performSegue(withIdentifier: "addChildSegue", sender: Any?.self)
    }
    
    @objc func removeChildSegue(_ sender : UIButton){
        self.performSegue(withIdentifier: "removeChildSegue", sender: Any?.self)
    }
    
    @objc func editChildSegue(_ sender : UIButton){
        self.performSegue(withIdentifier: "editChildSegue", sender: Any?.self)
    }
    
    @objc func proofSegue(_ sender : UIButton){
        self.performSegue(withIdentifier: "proofSegue", sender: Any?.self)
    }
    
    @objc func logoutTapped(_ sender : UIButton){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "adminLogout", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
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

}
