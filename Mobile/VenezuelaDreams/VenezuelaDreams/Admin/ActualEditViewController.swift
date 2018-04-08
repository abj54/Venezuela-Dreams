//
//  ActualEditViewController.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 4/7/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit
import Firebase

class ActualEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var child_image: UIImageView!
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    var child_id = String()
    
    var first_name = ""
    var last_name = ""
    var dob = ""
    var child_description = ""
    var child_img = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        getChild()
        // Do any additional setup after loading the view.
    }

    func setUp(){
        view.addSubview(nameTextField)
        nameTextField.topAnchor.constraint(equalTo: child_image.bottomAnchor, constant: 8).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -4).isActive = true
        nameTextField.delegate = self
        
        view.addSubview(lastNameTextField)
        lastNameTextField.topAnchor.constraint(equalTo: child_image.bottomAnchor, constant: 8).isActive = true
        lastNameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        lastNameTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        lastNameTextField.widthAnchor.constraint(equalToConstant: (view.frame.width/2)-16)
        lastNameTextField.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 4).isActive = true
        lastNameTextField.delegate = self
        
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
        
        view.addSubview(editChildButton)
        editChildButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        editChildButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        editChildButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        editChildButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        editChildButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        editChildButton.addTarget(self, action: #selector(self.handleUpload(_:)), for: .touchUpInside)
    }
    
    @objc func handleUpload(_ sender : UIButton){
        guard let fn = nameTextField.text, let ln = lastNameTextField.text, let des = descriptionTextView.text, let im = child_image.image, let date_birth = dobTextField.text else {
            print("Form is not valid")
            return
        }
        
        print(fn)
        print(self.first_name)
        if (date_birth == self.dob){
            print("the same")
        }
        if (fn == self.first_name && ln == self.last_name && des == self.child_description && im == self.child_img && date_birth == self.dob){
            let alertController = UIAlertController(title: "Message", message: "No change was made", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            print("THE SAME!!!")
        } else {
            print("DIFFERENT!!!!!!")
            addtoDbChild(first_name: fn, last_name: ln, date_of_birth: date_birth, image: im, description: des)
        }
    }
    
    //creates the user and adds to the database
    func addtoDbChild(first_name:String, last_name:String, date_of_birth:String, image:UIImage, description:String){
        startLoading()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY"
        let curr_date = dateFormatter.string(from: date)
        
        let values = ["first_name": first_name, "last_name": last_name, "date_of_birth": date_of_birth, "description": description, "date_updated": curr_date as String] as [String : Any]
        
        let dbRef = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        let childRef = dbRef.child("child").child(child_id)
        childRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if (err != nil){
                print(err ?? "")
                return
            }
            print("Saved child succesfully into db")
        })
        
        //Store picture in bucket
        let storage = Storage.storage(url: "gs://vzladreams.appspot.com/")
        let storageReference = storage.reference().child("children").child(child_id)
        
        var data = Data()
        data = UIImagePNGRepresentation(image)!
        
        let imageRef = storageReference.child("profile_pic.png")
        imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
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
                    "Child was edited succesfully!", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: {_ in
                    CATransaction.setCompletionBlock({
                        self.performSegue(withIdentifier: "afterEdit", sender: self)
                    })
                }))
                self.present(alertController, animated: true, completion: nil)
            })
        })
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
    
    func getChild(){
        let ref = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        let childRef = ref.child("child").child(child_id)
        
        childRef.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() { return }
            self.first_name = snapshot.childSnapshot(forPath: "first_name").value as! String
            self.last_name = snapshot.childSnapshot(forPath: "last_name").value as! String
            self.dob = snapshot.childSnapshot(forPath: "date_of_birth").value as! String
            let img_url = snapshot.childSnapshot(forPath: "img_url").value as! String
            self.child_description = snapshot.childSnapshot(forPath: "description").value as! String
            
            var picture = UIImage()
            let storageRef = Storage.storage().reference(forURL: img_url)
            storageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                } else {
                    print("LOADED ONE IMAGE!!!!!")
                    picture = UIImage(data: data!)!
                }
                print("Finished loading image!")
                self.child_img = picture
                self.child_image.image = picture
            }
            self.nameTextField.text = self.first_name
            self.lastNameTextField.text = self.last_name
            self.descriptionTextView.text = self.child_description
            self.dobTextField.text = self.dob
        }
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
        tf.keyboardType = .default
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
        tf.keyboardType = .default
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
        tf.keyboardType = .default
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
        bt.showsTouchWhenHighlighted = true
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
        child_image.image = image
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
        if (textField == dobTextField){
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = UIDatePickerMode.date
            textField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
        }
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dobTextField.text = dateFormatter.string(from: sender.date)
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
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func donePressed(_ sender: UIBarButtonItem) {
        dobTextField.resignFirstResponder()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
