//
//  LoginPageViewController.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 1/25/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginPageViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var inputsView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    
    var maleIsChecked = false
    var femaleIsChecked = false
    override func viewDidLoad() {
        super.viewDidLoad()

        setupInputView()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButtonHandle(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil);
    }
    
    //sets the inputsView
    func setupInputView(){
        //inputsView.backgroundColor = UIColor.black
        inputsView.layer.cornerRadius = 5
        inputsView.layer.borderWidth = 1
        inputsView.layer.masksToBounds = true
        
        //nameTextField
        inputsView.addSubview(nameTextField)
        nameTextField.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        nameTextField.heightAnchor.constraint(equalTo: inputsView.heightAnchor, multiplier: 1/5).isActive = true
        
        //nameSeparator
        inputsView.addSubview(nameSeparator)
        nameSeparator.leftAnchor.constraint(equalTo: inputsView.leftAnchor).isActive = true
        nameSeparator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparator.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        nameSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        //lastnameTextField
        inputsView.addSubview(lastnameTextField)
        lastnameTextField.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 12).isActive = true
        lastnameTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        lastnameTextField.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        lastnameTextField.heightAnchor.constraint(equalTo: inputsView.heightAnchor, multiplier: 1/5).isActive = true
        
        //lastNameSeparator
        inputsView.addSubview(lastNameSeparator)
        lastNameSeparator.leftAnchor.constraint(equalTo: inputsView.leftAnchor).isActive = true
        lastNameSeparator.topAnchor.constraint(equalTo: lastnameTextField.bottomAnchor).isActive = true
        lastNameSeparator.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        lastNameSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        //genderLabel
        inputsView.addSubview(genderLabel)
        genderLabel.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 12).isActive = true
        genderLabel.heightAnchor.constraint(equalTo: inputsView.heightAnchor, multiplier: 1/5).isActive = true
        genderLabel.topAnchor.constraint(equalTo: lastnameTextField.bottomAnchor).isActive = true
        genderLabel.sizeToFit()
        
        //maleButton
        inputsView.addSubview(maleButton)
        maleButton.topAnchor.constraint(equalTo: lastnameTextField.bottomAnchor, constant: 12.5).isActive = true
        maleButton.widthAnchor.constraint(equalTo: inputsView.widthAnchor, multiplier: 1/3).isActive = true
        maleButton.heightAnchor.constraint(equalTo: inputsView.heightAnchor, multiplier: 1/10).isActive = true
        maleButton.leftAnchor.constraint(equalTo: genderLabel.rightAnchor, constant: 10).isActive = true
        
        //femaleButton
        inputsView.addSubview(femaleButton)
        femaleButton.rightAnchor.constraint(equalTo: inputsView.rightAnchor, constant: 10)
        femaleButton.leftAnchor.constraint(equalTo: maleButton.rightAnchor, constant: 5).isActive = true
        femaleButton.topAnchor.constraint(equalTo: lastnameTextField.bottomAnchor, constant: 12.5).isActive = true
        femaleButton.widthAnchor.constraint(equalTo: inputsView.widthAnchor, multiplier: 1/3).isActive = true
        femaleButton.heightAnchor.constraint(equalTo: inputsView.heightAnchor, multiplier: 1/10).isActive = true
        
        //genderSeparator
        inputsView.addSubview(genderSeparator)
        genderSeparator.leftAnchor.constraint(equalTo: inputsView.leftAnchor).isActive = true
        genderSeparator.topAnchor.constraint(equalTo: genderLabel.bottomAnchor).isActive = true
        genderSeparator.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        genderSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        //emailTextField
        inputsView.addSubview(emailTextField)
        emailTextField.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: genderSeparator.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: inputsView.heightAnchor, multiplier: 1/5).isActive = true
        
        //emailSeparator
        inputsView.addSubview(emailSeparator)
        emailSeparator.leftAnchor.constraint(equalTo: inputsView.leftAnchor).isActive = true
        emailSeparator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparator.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        emailSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        //passwordTextField
        inputsView.addSubview(passwordTextField)
        passwordTextField.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: inputsView.heightAnchor, multiplier: 1/5).isActive = true
        
        submitButton.layer.cornerRadius = 5
        submitButton.layer.borderWidth = 1
        submitButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.borderWidth = 1
        
        maleButton.addTarget(self, action: #selector(handleGenderButtons), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(handleGenderButtons), for: .touchUpInside)
    }
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
        tf.textColor = UIColor.black
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let lastnameTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
        tf.textColor = UIColor.black
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let lastNameSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let genderLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Gender:"
        lb.textColor = UIColor.black
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    let maleButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Male", for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.layer.borderWidth = 1
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = #colorLiteral(red: 0.1149336117, green: 0.542532519, blue: 0.09051094183, alpha: 1).cgColor
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
    
    let femaleButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Female", for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.layer.borderWidth = 1
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = #colorLiteral(red: 0.1149336117, green: 0.542532519, blue: 0.09051094183, alpha: 1).cgColor
        bt.tintColor = #colorLiteral(red: 0.1149336117, green: 0.542532519, blue: 0.09051094183, alpha: 1)
        bt.translatesAutoresizingMaskIntoConstraints = false
        return bt
    }()
    
    let genderSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
        tf.textColor = UIColor.black
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
        tf.textColor = UIColor.black
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    //handle registration of user through email
    @objc func handleRegister(){
        
        //get email, password, name, and lastname
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let lastname = lastnameTextField.text else {
            print("Form is not valid")
            return
        }
        
        var gender = ""
        //if gender is male, create user if the male gender
        if (maleIsChecked){
            gender = "male"
            createAndAddtoDbUser(name: name, lastname: lastname, email: email, password: password, gender: gender)
            
            //if gender is female, create user if the female gender
        } else if (femaleIsChecked){
            gender = "female"
            createAndAddtoDbUser(name: name, lastname: lastname, email: email, password: password, gender: gender)
            
            //if gender is empty, prompt user to enter one
        } else if (gender == ""){
            print("Please specify gender")
            let alertController = UIAlertController(title: "Form is not valid!", message:
                "Please, enter gender!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //creates the user and adds to the database
    func createAndAddtoDbUser(name:String, lastname:String, email:String, password:String, gender:String){
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
            
            //if error is not null then prompt user error
            if (error != nil){
                print(error ?? "")
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode{
                    //if the email already exists
                    case .emailAlreadyInUse:
                        let alertController = UIAlertController(title: "Not a valid email!", message:
                            "Email is already taken", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                    //if the email entered is not valid
                    case .invalidEmail:
                        let alertController = UIAlertController(title: "Not a valid email!", message:
                            "That is not a vaid email", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                    //otherwise return the error
                    default:
                        print("Error creating user: \(String(describing: error))")
                    }
                    
                }
                return
            }
            
            //gets the user's id
            guard let uid = user?.uid else{
                return
            }
            let ref = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
            let values = ["name": name, "lastname": lastname, "email": email, "gender": gender]
            let usersReference = ref.child("user").child("email_users").child(uid)
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                
                if (err != nil){
                    print(err ?? "")
                    return
                }
                print("Saves user succesfully into db")
                self.performSegue(withIdentifier: "redirectAfterSignupEmail", sender: self)
            })
        })
    }
    
    //handle of the gender buttons, meaning that only one can be clicked
    @objc func handleGenderButtons(){
        if (maleButton.state == .highlighted){
            if (maleIsChecked == false){
                maleButton.backgroundColor = #colorLiteral(red: 0.1149336117, green: 0.542532519, blue: 0.09051094183, alpha: 1)
                maleButton.setTitleColor(.black, for: .normal)
                maleIsChecked = true
                print("maleChecked and femaleUnchecked")
                femaleButton.backgroundColor = .black
                femaleButton.setTitleColor(.lightText, for: .normal)
                femaleIsChecked = false
            } else if (maleIsChecked == true){
                maleButton.backgroundColor = .black
                maleButton.setTitleColor(.lightText, for: .normal)
                maleIsChecked = false
                print("maleUnchecked")
            }
        }
        if (femaleButton.state == .highlighted){
            if (femaleIsChecked == false){
                femaleButton.backgroundColor = #colorLiteral(red: 0.1149336117, green: 0.542532519, blue: 0.09051094183, alpha: 1)
                femaleButton.setTitleColor(.black, for: .normal)
                femaleIsChecked = true
                print("femaleChecked and male Unchecked")
                maleButton.backgroundColor = .black
                maleButton.setTitleColor(.lightText, for: .normal)
                maleIsChecked = false
            } else if (femaleIsChecked == true){
                femaleButton.backgroundColor = .black
                femaleButton.setTitleColor(.lightText, for: .normal)
                femaleIsChecked = false
                print("femaleUnchecked")
            }
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
