//
//  AddChildViewController.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 3/27/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit
import Firebase

class AddChildViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var childImage: UIImageView!
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        // Do any additional setup after loading the view.
    }

    func setUp(){
        view.addSubview(nameTextField)
        nameTextField.topAnchor.constraint(equalTo: childImage.bottomAnchor, constant: 8).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -4).isActive = true
        
        view.addSubview(lastNameTextField)
        lastNameTextField.topAnchor.constraint(equalTo: childImage.bottomAnchor, constant: 8).isActive = true
        lastNameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        lastNameTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        lastNameTextField.widthAnchor.constraint(equalToConstant: (view.frame.width/2)-16)
        lastNameTextField.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 4).isActive = true

        descriptionTextView.delegate = self
        view.addSubview(descriptionTextView)
        descriptionTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        descriptionTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        setUpDatePicker()
        
        view.addSubview(choosePictureButton)
        choosePictureButton.topAnchor.constraint(equalTo: dobTextField.bottomAnchor, constant: 8).isActive = true
        choosePictureButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        choosePictureButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        choosePictureButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        choosePictureButton.addTarget(self, action: #selector(self.openPhotoLibraryButton(sender:)), for: .touchUpInside)
        
        view.addSubview(addChildButton)
        addChildButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addChildButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        addChildButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        addChildButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        addChildButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addChildButton.addTarget(self, action: #selector(self.handleUpload(_:)), for: .touchUpInside)
    }
    
    func setUpDatePicker(){
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 35.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.black
        
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 15)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.text = "Date of Birth"
        label.textAlignment = NSTextAlignment.center
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
        dobTextField.delegate = self
        view.addSubview(dobTextField)
        dobTextField.inputAccessoryView = toolBar
        dobTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        dobTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        dobTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 8).isActive = true
        dobTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    //handle registration of user through email
    @objc func handleUpload(_ sender : UIButton){
        guard let first_name = nameTextField.text, let last_name = lastNameTextField.text, let description = descriptionTextView.text, let image = childImage.image, let date_of_birth = dobTextField.text else {
            print("Form is not valid")
            return
        }
        
        addtoDbChild(first_name: first_name, last_name: last_name, date_of_birth: date_of_birth, image: image, description: description)
    }
    
    //creates the user and adds to the database
    func addtoDbChild(first_name:String, last_name:String, date_of_birth:String, image:UIImage, description:String){
        startLoading()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY"
        let curr_date = dateFormatter.string(from: date)

        let values = ["first_name": first_name, "last_name": last_name, "date_of_birth": date_of_birth, "description": description, "date_created": curr_date as String] as [String : Any]
        
        let dbRef = FIRDatabase.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        let childRef = dbRef.child("child").childByAutoId()
        let childId = childRef.key
        childRef.updateChildValues(values, withCompletionBlock: { (err, ref) in

            if (err != nil){
                print(err ?? "")
                return
            }
            print("Saved child succesfully into db")
        })
        
        //Store picture in bucket
        let storage = FIRStorage.storage(url: "gs://vzladreams.appspot.com/")
        let storageReference = storage.reference().child("children").child(childId)
        
        var data = Data()
        data = UIImagePNGRepresentation(image)!
        
        let imageRef = storageReference.child("profile_pic.png")
        imageRef.put(data, metadata: nil, completion: { (metadata,error ) in
            guard let metadata = metadata else{
                    print(error!)
                    return
            }
            print("Saved picture succesfully in storage!")
            let downloadURL = metadata.downloadURL()
            let url = downloadURL?.absoluteString
            childRef.updateChildValues(["img_url": url!], withCompletionBlock: { (err, ref) in
                if (err != nil){
                    print(err ?? "")
                    return
                }
                print("Saved picture of child succesfully into db")
                self.stopLoading()
                let alertController = UIAlertController(title: "Success!!", message:
                    "Child was added succesfully!", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: {_ in
                    CATransaction.setCompletionBlock({
                        self.performSegue(withIdentifier: "redirectAfterAddChild", sender: self)
                    })
                }))
                self.present(alertController, animated: true, completion: nil)
            })
        })
    }
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Child First Name:", attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray])
        tf.textColor = UIColor.black
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5
        tf.layer.borderColor = UIColor.black.cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clipsToBounds = true
        tf.textAlignment = .center
        return tf
    }()
    
    let lastNameTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Child Last Name:", attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray])
        tf.textColor = UIColor.black
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5
        tf.layer.borderColor = UIColor.black.cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clipsToBounds = true
        tf.textAlignment = .center
        return tf
    }()
    
    let descriptionTextView: UITextView = {
        let tf = UITextView()
        tf.textColor = UIColor.black
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5
        tf.layer.borderColor = UIColor.black.cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clipsToBounds = true
        tf.font = .systemFont(ofSize: 18)
        tf.text = "Child description: I like to play soccer and I want to be a fireman when I grow up!"
        tf.textColor = UIColor.lightGray
        return tf
    }()
    
    let choosePictureButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Choose Picture", for: .normal)
        bt.setTitleColor(UIColor.black, for: .normal)
        bt.backgroundColor = UIColor.magenta
        bt.layer.borderWidth = 1.0
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor.black.cgColor
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.clipsToBounds = true
        return bt
    }()
    
    let dobTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Child Date Of Birth: Month/Day/Year", attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray])
        tf.textColor = UIColor.black
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5
        tf.layer.borderColor = UIColor.black.cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clipsToBounds = true
        tf.textAlignment = .center
        return tf
    }()

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
        bt.showsTouchWhenHighlighted = true
        return bt
    }()
    
    let backButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("< Back", for: .normal)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.clipsToBounds = true
        return bt
    }()
    
    @objc func openPhotoLibraryButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        childImage.image = image
        dismiss(animated:true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Child description: I like to play soccer and I want to be a fireman when I grow up!"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        textField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    func startLoading(){
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray;
        view.addSubview(activityIndicator);
        
        activityIndicator.startAnimating();
        UIApplication.shared.beginIgnoringInteractionEvents();
        
    }
    
    func stopLoading(){
        activityIndicator.stopAnimating();
        UIApplication.shared.endIgnoringInteractionEvents();
        
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dobTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func donePressed(_ sender: UIBarButtonItem) {
        dobTextField.resignFirstResponder()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
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
