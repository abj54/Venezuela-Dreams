//
//  RemoveChildViewController.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 3/29/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit
import Firebase

class RemoveChildViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var dictionaryChildren = [Int : [String : String]]()
    var dictioanaryImg = [Int : [String : UIImage]]()
    var numberOfChildren = Int()
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();

    
    @IBOutlet weak var testImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        getChildren()
    
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setUp(){
        view.addSubview(removeChildButton)
        removeChildButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        removeChildButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        removeChildButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        removeChildButton.addTarget(self, action: #selector(self.removeChild(_:)), for: .touchUpInside)
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
                        print("LOADED ONE IMAGE!!!!!")
                        picture = UIImage(data: data!)!
                        self.dictioanaryImg[count] = [id : picture]
                    }
                    print("Finished loading image!")
                    self.tableView.reloadData()
                }
                
                count = count + 1
                self.tableView.reloadData()
            }
        }
    }
    
    func printDictionary(){
        print("AFTER THE FUNCTION: \(self.dictionaryChildren)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("THIS IS THE NUMBER \(self.numberOfChildren)")
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

        self.removeChildButton.isEnabled = true
    }
    
    @objc func removeChild(_ sender: UIButton){
        
        
        let indexPath = tableView.indexPathForSelectedRow
        let cell = tableView.cellForRow(at: indexPath!) as! RemoveTableViewCell
        let name = cell.nameCell.text
        let id = cell.child_id.text
        
        let alertController = UIAlertController(title: "Message", message: "Are you sure you want to remove: \(name!)", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
            self.removeFromDb(id: id!)
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func removeFromDb(id: String){
        let dbRef = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        let childRef = dbRef.child("child").child(id)
        childRef.removeValue { error, _ in
            if (error == nil){
                print("Removed successfully! \(id)")
                self.getChildren()
            } else {
                print(error!)
            }
        }
        
        let storage = Storage.storage(url: "gs://vzladreams.appspot.com/")
        let storageReference = storage.reference().child("children").child(id).child("profile_pic.png")
        storageReference.delete(completion: {error in
            if (error == nil){
                print("Successfully deleted picture!!")
            } else {
                print(error!)
            }
        })
        
    }
    
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
        bt.isEnabled = false
        bt.showsTouchWhenHighlighted = true
        return bt
    }()
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
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
