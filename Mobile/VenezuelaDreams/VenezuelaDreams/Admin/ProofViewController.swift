//
//  ProofViewController.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 4/8/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit
import Firebase
import Photos

class ProofViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var dictionaryChildren = [Int : [String : String]]()
    var dictioanaryImg = [Int : [String : UIImage]]()
    var numberOfChildren = Int()
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    var child_id = ""
    var child_name = ""
    
    var imagePicker : UIImagePickerController = UIImagePickerController()
    var proofImage = UIImage()
    
    @IBOutlet weak var childTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        getChildren()
        
        childTableView.dataSource = self
        childTableView.delegate = self
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func setUp(){
        view.addSubview(uploadProofButton)
        uploadProofButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        uploadProofButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        uploadProofButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        uploadProofButton.addTarget(self, action: #selector(self.addPictureBtnAction(_:)), for: .touchUpInside)
    }

    func getChildren(){
        let ref = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        let childRef = ref.child("child")
        
        childRef.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() { return }
            self.numberOfChildren = Int(snapshot.childrenCount)
            // print(snapshot.childrenCount) // I got the expected number of items
            let enumerator = snapshot.children
            var count = 0
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let first_name = rest.childSnapshot(forPath: "first_name").value as! String
                let last_name = rest.childSnapshot(forPath: "last_name").value as! String
                let date_of_birth = rest.childSnapshot(forPath: "date_of_birth").value as! String
                let img_url = rest.childSnapshot(forPath: "img_url").value as! String
                let id = rest.key
                let values = ["first_name": first_name, "last_name": last_name, "date_of_birth": date_of_birth, "child_id": id, "img_url": img_url]
                
                self.dictionaryChildren[count] = values
                
                var picture = UIImage()
                let storageRef = Storage.storage().reference(forURL: img_url)
                storageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error)
                    } else {
                        picture = UIImage(data: data!)!
                        self.dictioanaryImg[count] = [id : picture]
                    }
                    self.childTableView.reloadData()
                }
                
                count = count + 1
                self.childTableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfChildren
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "removeCell") as! RemoveTableViewCell
        
        let snapshot = self.dictionaryChildren[indexPath.row]
        let name = snapshot!["first_name"]! + " " + snapshot!["last_name"]!
        let date = snapshot!["date_of_birth"]!
        let child_id = snapshot!["child_id"]!
        
        let imageDic = self.dictioanaryImg[indexPath.row]
        var img = UIImage()
        if (imageDic != nil){
            img = imageDic![child_id]!
        }
        
        cell.nameCell.text = name
        cell.dateCell.text = date
        cell.pictureCell.image = img
        cell.child_id.text = child_id
        
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = UIColor.lightGray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.uploadProofButton.isEnabled = true
    }
    
    let uploadProofButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Upload Proof", for: .normal)
        bt.setTitleColor(UIColor.white, for: .normal)
        bt.backgroundColor = UIColor(red:66.0/255.0, green:69.0/255.0, blue:112.0/255.0, alpha:255.0/255.0)
        bt.layer.borderWidth = 1.0
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor(red:14.0/255.0, green:211.0/255.0, blue:140.0/255.0, alpha:255.0/255.0).cgColor
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.clipsToBounds = true
        bt.isEnabled = false
        bt.showsTouchWhenHighlighted = true
        return bt
    }()
    
    @objc func addPictureBtnAction(_ sender: UIButton) {
        let indexPath = childTableView.indexPathForSelectedRow
        let cell = childTableView.cellForRow(at: indexPath!) as! RemoveTableViewCell
        let id = cell.child_id.text
        self.child_id = id!
        self.child_name = cell.nameCell.text!
        
        
        uploadProofButton.isEnabled = false
        
        let alertController : UIAlertController = UIAlertController(title: "Upload Proof to \(child_name)", message: "Select Camera or Photo Library", preferredStyle: .actionSheet)
        let cameraAction : UIAlertAction = UIAlertAction(title: "Camera", style: .default, handler: {(cameraAction) in
            print("camera Selected...")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
                
                self.imagePicker.sourceType = .camera
                self.present()
            }else{
                self.present(self.showAlert(Title: "Title", Message: "Camera is not available on this Device or accesibility has been revoked!"), animated: true, completion: nil)
            }
        })
        
        let libraryAction : UIAlertAction = UIAlertAction(title: "Photo Library", style: .default, handler: {(libraryAction) in
            
            print("Photo library selected....")

            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) == true {
                self.imagePicker.sourceType = .photoLibrary
                self.present()
            }else{
                self.present(self.showAlert(Title: "Message", Message: "Photo Library is not available on this Device or accesibility has been revoked!"), animated: true, completion: nil)
            }
        })
        
        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel , handler: {(cancelActn) in
            print("Cancel action was pressed")
        })
        
        alertController.addAction(cameraAction)
        
        alertController.addAction(libraryAction)
        
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func present(){
        self.present(imagePicker, animated: true, completion: nil)
    }

    //Show Alert
    func showAlert(Title : String!, Message : String!)  -> UIAlertController {
        
        let alertController : UIAlertController = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        let okAction : UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (alert) in
            print("User pressed ok function")
            
        }
        
        alertController.addAction(okAction)
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame
        
        return alertController
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        proofImage = chosenImage //4
        dismiss(animated:true, completion: nil) //5
        addProofToStorage()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addProofToStorage(){
        self.startLoading()
        let storage = Storage.storage(url: "gs://vzladreams.appspot.com/")
        let storageReference = storage.reference().child("proof_images").child(child_id)
        let dbRef = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        let childRef = dbRef.child("child").child(child_id)
        
        var data = Data()
        data = UIImagePNGRepresentation(proofImage)!
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY"
        let curr_date = dateFormatter.string(from: date)
        let imageRef = storageReference.child(curr_date)
        imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
            guard let metadata = metadata else{
                print(error!)
                return
            }
            print("Saved picture succesfully in storage!")
            let downloadURL = metadata.downloadURL()
            let url = downloadURL?.absoluteString
            childRef.updateChildValues(["proof_img_url": url!], withCompletionBlock: { (err, ref) in
                if (err != nil){
                    print(err ?? "")
                    return
                }
                print("Saved picture of child succesfully into db")
                let alertController = UIAlertController(title: "Success!!", message:
                    "Proof was added succesfully to \(self.child_name)", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            })
            self.stopLoading()
        })
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

