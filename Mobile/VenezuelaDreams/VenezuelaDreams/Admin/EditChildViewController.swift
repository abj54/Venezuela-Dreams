//
//  EditChildViewController.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 4/7/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit
import Firebase

class EditChildViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var dictionaryChildren = [Int : [String : String]]()
    var dictioanaryImg = [Int : [String : UIImage]]()
    var numberOfChildren = Int()
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    var child_id = ""
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        getChildren()
        
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }

    func setUp(){
        view.addSubview(editChildButton)
        editChildButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        editChildButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        editChildButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        editChildButton.addTarget(self, action: #selector(self.editChild(_:)), for: .touchUpInside)
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
        
        self.editChildButton.isEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editChild" {
            if let destination = segue.destination as? ActualEditViewController {
                destination.child_id = self.child_id
            }
        }
    }
    
    @objc func editChild(_ sender: UIButton){
        let indexPath = tableView.indexPathForSelectedRow
        let cell = tableView.cellForRow(at: indexPath!) as! RemoveTableViewCell
        let id = cell.child_id.text
        self.child_id = id!
        self.performSegue(withIdentifier: "editChild", sender: self)
    }
    
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
        bt.isEnabled = false
        bt.showsTouchWhenHighlighted = true
        return bt
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }

}
