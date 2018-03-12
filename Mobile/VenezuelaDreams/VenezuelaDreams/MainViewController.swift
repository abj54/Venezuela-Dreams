//
//  MainViewController.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 1/25/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase


class MainViewController: UIViewController,UIScrollViewDelegate  {
    
    
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var settings: UIButton!
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    var image: UIImage!

    var refChild: FIRDatabaseReference!
    var array_pages = [DatabaseChild]()

    //First method that runs
    //Main method for View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get all the children from firebase
        refChild = FIRDatabase.database().reference().child("child")
        refChild.observe(FIRDataEventType.value, with: {(snapshot) in
            if(snapshot.childrenCount > 0){
                self.array_pages.removeAll()
                
                for databasechildren in snapshot.children.allObjects as![FIRDataSnapshot]{
                    let childObject = databasechildren.value as? [String: AnyObject]
                    let childName = childObject?["first_name"]
                    let childDescription = childObject?["description"]
                    let childID = databasechildren.key as! String
                    let imageUrl = childObject?["imageurl"]
                    
                    //FIX IT
                    let child = DatabaseChild(id: childID, name: childName as! String, description: childDescription as? String, childUrl: imageUrl  as? String)
                    self.array_pages.append(child)
                }
            }
            self.setUpScroll()
            self.loadPages()
        })
        //print(FIRAuth.auth()?.currentUser!.uid as Any)

    }

    func loadChildImage(){
        
    }
    
    //Sets properties of scroll view
    func setUpScroll(){
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(array_pages.count), height: self.scrollView.bounds.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
    }
    
    //Loads scroll view with cards of the children
    func loadPages(){

        for (index,childObject) in array_pages.enumerated(){
            let card = MainCard(frame: CGRect(x: 0, y: 0, width: 355 , height: self.scrollView.bounds.height))
            card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
            //card.icon = UIImage(named: "flappy")
            //card.category = page["name"]!
            card.categoryLbl.textColor = UIColor.white
            card.title = childObject.name! //Name
            card.subtitle = childObject.description! //Bio
            card.blurEffect = .light
            //card.itemTitle = page["name"]!
            //card.itemSubtitle = "Flap That !"
            //loadImage(childID: childObject.id!)
            //GET IMAGE
            let imageUrlString = childObject.childUrl
            let imageUrl:URL = URL(string: imageUrlString!)!
            
            // Start background thread so that image loading does not make app unresponsive
            DispatchQueue.global(qos: .userInitiated).async {
                
                let imageData:NSData = NSData(contentsOf: imageUrl)!
                let imageView = UIImageView(frame: CGRect(x:0, y:0, width:200, height:200))
                imageView.center = self.view.center
                
                // When from background thread, UI needs to be updated on main_queue
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData as Data)
                    card.backgroundImage = image
                }
            }
            
            
            //card.backgroundColor = UIColor.clear
            card.textColor = UIColor.white
            card.hasParallax = true
            let cardContentVC = storyboard!.instantiateViewController(withIdentifier: "CardContent")
            card.shouldPresent(cardContentVC, from: self, fullscreen: false)
            
            scrollView.addSubview(card)
            
            //set origin of x coordinate for the card
            if (index == 0){
                card.frame.origin.x = (self.view.bounds.width - 355) / 2
            } else {
                card.frame.origin.x = (CGFloat(index) * self.scrollView.bounds.width) + ((self.view.bounds.width - 355) / 2)
            }
            card.frame.origin.y = 0
        }
    }


    
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func goToWelcome(_ sender: Any) {
        doSegue()
    }
    func doSegue(){
        self.performSegue(withIdentifier: "goToWelcome", sender: self)
    }

    @IBAction func goToSettings(_ sender: Any) {
        doSegueSettings()
    }
    func doSegueSettings(){
        self.performSegue(withIdentifier: "toSettings", sender: self)
    }
}
