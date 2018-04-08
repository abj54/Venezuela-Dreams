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
    
    //Segue buttons
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var settings: UIButton!
    
    //Donate buttons
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var donateRandomly: UIButton!
    
    //Scroll through children variables
    @IBOutlet weak var scrollView: UIScrollView!
    var refChild: DatabaseReference!
    var array_pages = [DatabaseChild]()

    //First method that runs
    //Main method for View
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get all the children from firebase
        
        refChild = Database.database().reference().child("child")
        refChild.observe(DataEventType.value, with: {(snapshot) in
            if(snapshot.childrenCount > 0){
                self.array_pages.removeAll()
                for databasechildren in snapshot.children.allObjects as![DataSnapshot]{
                    let childObject = databasechildren.value as? [String: AnyObject]
                    let childName = (childObject?["first_name"] as! String) + " " + (childObject?["last_name"] as! String)
                    let childDescription = childObject?["description"]
                    //let childID = databasechildren.key as! String
                    //let imageUrl = childObject?["img_url"]
                    let childID = databasechildren.key
                    let imageUrl = childObject?["img_url"]
                    
                    //FIX IT
                    let child = DatabaseChild(id: childID, name: childName, description: childDescription as? String, childUrl: imageUrl  as? String)
                    self.array_pages.append(child)
                }
            }
            self.setUpScroll()
            self.loadPages()
        })
        //print(FIRAuth.auth()?.currentUser!.uid as Any)

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

            card.categoryLbl.textColor = UIColor.white
            card.title = childObject.name! //Name
            card.subtitle = childObject.description! //Bio
            card.blurEffect = .light

            //GET IMAGE
            // http://swiftdeveloperblog.com/code-examples/uiimageview-and-uiimage-load-image-from-remote-url/
            let imageUrlString = childObject.childUrl
            let imageUrl:URL = URL(string: imageUrlString!)!
            // Start background thread so that image loading does not make app unresponsive
            DispatchQueue.global(qos: .userInitiated).async {
                if let url:URL = URL(string: imageUrlString!), let data:NSData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        let image = UIImage(data: data as Data)
                        card.backgroundImage = image
                    }
                } else {
                    //If image cannot be retreived, use default image
                    print("something went wrong")
                    card.backgroundImage = UIImage(named: "unknownperson")
                }
            }

            //card.backgroundColor = UIColor.clear
            card.textColor = UIColor.white
            card.hasParallax = true
            //INITIALIZE VIEW CONTROLLER
            let cardContentVC = storyboard!.instantiateViewController(withIdentifier: "DonateButtonViewController") as! DonateButtonViewController
            //TRANSFER CHILD ID TO DONATE VIEW CONTROLLER
            cardContentVC.transferChildID = childObject.id as? String
            
            card.shouldPresent(cardContentVC, from: self, fullscreen: false)
            //set origin of x and y coordinates for the card
            if (index == 0){
                card.frame.origin.x = (self.view.bounds.width - 355) / 2
            } else {
                card.frame.origin.x = (CGFloat(index) * self.scrollView.bounds.width) + ((self.view.bounds.width - 355) / 2)
            }
            card.frame.origin.y = 0
            scrollView.addSubview(card)

        }
    }

    //Donation Actions
    
    //Donate to random child
    //Note: This only chooses one from those who are loaded
    @IBAction func donateRandomPressed(_ sender: Any) {
        let randomIndex = Int(arc4random_uniform(UInt32(array_pages.count)))
        let randomlyChosen = array_pages[randomIndex]
        let myVC = storyboard?.instantiateViewController(withIdentifier: "DonationViewController") as! DonationViewController
        myVC.childToDonateToID = randomlyChosen.id
        self.present(myVC, animated:true, completion:nil)
    }
    
    //Donate to current child
    @IBAction func donateButtonPressed(_ sender: Any) {
        var page = scrollView.contentOffset.x / scrollView.frame.size.width
        let chosenChild = array_pages[Int(page)]
        let myVC = storyboard?.instantiateViewController(withIdentifier: "DonationViewController") as! DonationViewController
        myVC.childToDonateToID = chosenChild.id
        self.present(myVC, animated:true, completion:nil)
    }
    

    
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: xIStoryboardSegue, sender: Any?) {
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
    
    func doSegueSettings(){
    self.performSegue(withIdentifier: "toSettings", sender: self)
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        doSegueSettings()
    }
    


}
