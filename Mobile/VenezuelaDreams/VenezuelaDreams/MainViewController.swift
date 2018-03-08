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
    var images = [UIImage]()
    

    var array_pages = [Dictionary<String, String>]()

    override func viewDidLoad() {
        super.viewDidLoad()
        images = [UIImage(named: "pascal")!,UIImage(named: "jeff")!,UIImage(named: "andres")!]
        array_pages = getInitialImages()
        setUpScroll()
        
        print(FIRAuth.auth()?.currentUser!.uid as Any)

    }
    
    func getInitialImages() -> [Dictionary<String, String>] {
        let profile_one = ["name":"Pascal","bio":"Pascal is 6 years old and likes to play chess and soccer.","image":"pascal"]
        let profile_two = ["name":"Jeff","bio":"Jeff is 8 years old and likes to play tennis.","image":"jeff"]
        let profile_three = ["name":"Child","bio":"child child child child child child child child child child child child child child child child child child child child .","image":"pascal"]
        
        return [profile_one,profile_two,profile_three]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPages()
    }

    func loadImages(){
        // Do any additional setup after loading the view.
        for i in 0..<images.count {
            let imageView = UIImageView()
            let x = self.view.frame.size.width * CGFloat(i)
            imageView.frame = CGRect(x: x, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            imageView.contentMode = .scaleAspectFit
            imageView.image = images[i]
            scrollView.contentSize.width = scrollView.frame.size.width * CGFloat(i + 1)
            scrollView.addSubview(imageView)
        }
        
        scrollView.isPagingEnabled = true
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
    }
    
    func setUpScroll(){
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(array_pages.count), height: self.scrollView.bounds.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
 
    }
    
    func loadPages(){
        for (index, page) in array_pages.enumerated(){
            let card = MainCard(frame: CGRect(x: 0, y: 58, width: self.scrollView.bounds.width-40 , height: self.scrollView.bounds.height))
            card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
            //card.icon = UIImage(named: "flappy")
            //card.category = page["name"]!
            card.categoryLbl.textColor = UIColor.white
            card.title = page["name"]!
            card.subtitle = page["bio"]!
            card.blurEffect = .light
            //card.itemTitle = page["name"]!
            //card.itemSubtitle = "Flap That !"
            card.backgroundImage = UIImage(named: page["image"]!)
            //card.backgroundColor = UIColor.clear
            card.textColor = UIColor.white
            card.hasParallax = true
            let cardContentVC = storyboard!.instantiateViewController(withIdentifier: "CardContent")
            card.shouldPresent(cardContentVC, from: self, fullscreen: false)
            
            scrollView.addSubview(card)
            
            //set origin of x coordinate for the card
            if (index == 0){
                card.frame.origin.x = ((self.view.bounds.width - self.scrollView.bounds.width) / 2)+20
            } else {
                card.frame.origin.x = ((CGFloat(index) * self.scrollView.bounds.width) + ((self.view.bounds.width - self.scrollView.bounds.width) / 2))+20
            }
            //set origin of the y coordinate for the card
            
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
