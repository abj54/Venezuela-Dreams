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
    

    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var settings: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

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
                    let imageUrl = childObject?["img_url"]
                    
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
            var imageUrlString = childObject.childUrl
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
    
    @IBAction func goToDonate(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "DonationViewController") as! DonationViewController
        myVC.childToDonateToID = "1"
        self.present(myVC, animated:true, completion:nil)
    }

}
