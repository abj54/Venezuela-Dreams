//
//  ViewController.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 1/25/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class WelcomePageViewController: UIViewController, FBSDKLoginButtonDelegate, UIScrollViewDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonFB: FBSDKLoginButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let about_us = ["title": "About us", "text": "We are a team that helps children in Venezuela eat their 3 meals a day. By receaving donations as little as 2$", "image": "delta2"]
    let our_mission = ["title": "Our mission", "text": "Our mission is to help children in Venezuela and help foundations raise money", "image": "delta1"]
    let how_it_works = ["title": "How it works", "text": "Select a child and then donate a amount of at leat 2$, between 1 week and 2 weeks you will receive a confirmation that the child received the food!", "image": "delta3"]
    var array_pages = [Dictionary<String, String>]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //checkUserIsLogged()
        array_pages = [about_us, our_mission, how_it_works]
        setUpButtons()
        setUpScroll()
    }
    
    //This happens after the autolayout is done. So, any calculation done with autolayout number, it has to occur here
    override func viewDidAppear(_ animated: Bool) {
        loadPages()
       
    }

    //Set buttons of the view
    func setUpButtons(){
        loginButtonFB.delegate = self
        loginButtonFB.readPermissions = ["email", "public_profile"]
        loginButtonFB.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 0
        
        continueButton.layer.cornerRadius = 5
        continueButton.layer.borderWidth = 0
    }
    
    //Set scrollView
    func setUpScroll(){
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(array_pages.count), height: self.scrollView.bounds.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
    }
    
    //Load the three cards in the view
    func loadPages(){
        for (index, page) in array_pages.enumerated(){
            let card = CardArticle(frame: CGRect(x: 10, y: 30, width: self.loginButton.bounds.width , height: self.scrollView.bounds.height))
            card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
            card.category = page["title"]!
            card.categoryLbl.textColor = UIColor.white
            card.title = ""
            card.subtitle = page["text"]!
            card.blurEffect = .light
            card.backgroundImage = UIImage(named: page["image"]!)
            card.textColor = UIColor.white
            card.hasParallax = true
            var cardContentVC = storyboard?.instantiateInitialViewController()
            print(page["title"]!)
            if (page["title"]! == "How it works"){
                cardContentVC = storyboard!.instantiateViewController(withIdentifier: "CardContentHow")
            } else if (page["title"]! == "About us"){
                cardContentVC = storyboard!.instantiateViewController(withIdentifier: "CardContentAbout")
            } else {
                cardContentVC = storyboard!.instantiateViewController(withIdentifier: "CardContentMission")
            }
            card.shouldPresent(cardContentVC, from: self, fullscreen: false)
        
            //set origin of x coordinate for the card
            if (index == 0){
                card.frame.origin.x = (self.view.bounds.width - self.loginButton.bounds.width) / 2
            } else {
            card.frame.origin.x = (CGFloat(index) * self.scrollView.bounds.width) + ((self.view.bounds.width - self.loginButton.bounds.width) / 2)
            }
            //set origin of the y coordinate for the card
            
            card.frame.origin.y = 0
            scrollView.addSubview(card)

        }
    }
    
    //Change the page number
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(page)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did logout of FB")
    }
    
    //Sign up/Login with Facebook
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        //print error
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        print("Logged succesfully with FB")
        //create credentials for Firebase Auth and create the user in the Auth
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print(error.debugDescription)
                return
            } else {
                print(result)
                print("Succesfully passed in the data")
                //gets the user's id
                guard let uid = user?.uid else{
                    return
                }
                //method from FBSDK to get data
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, gender, email"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        let fbDetails = result as! NSDictionary
                        //get email, name, lastname, gender from fb
                        let email = fbDetails.value(forKeyPath: "email") as! String
                        let name = fbDetails.value(forKeyPath: "first_name") as! String
                        let lastname = fbDetails.value(forKeyPath: "last_name") as! String
                        let gender = fbDetails.value(forKeyPath: "gender") as! String
                        //call methos to add to the db with the repective parameters
                        self.addToDbFacebookUser(name: name, lastname: lastname, email: email, gender: gender, uid: uid)
                        print("\(email)\n  \(name)\n  \(lastname)\n  \(gender)")
                    } else {
                        print(error ?? "")
                        return
                    }
                })
                //do segue to main window
                //self.saveStripeId()
            }
        }
    }
    
    //add user's info to database
    func addToDbFacebookUser(name: String, lastname: String, email: String, gender: String, uid: String){
        let ref = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        let values = ["name": name, "lastname": lastname, "email": email, "gender": gender, "registration_type": "fb"]
        let usersReference = ref.child("user").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if (err != nil){
                print(err ?? "")
                return
            }
            print("Saved user succesfully into db")
        })
    }
    
    //Check if there is an user logged in to redirect
    func checkUserIsLogged(){
        let ref = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                print("THIS IS THE UID: \(String(describing: Auth.auth().currentUser?.uid))")
                let userReference = ref.child("user").child((Auth.auth().currentUser?.uid)!)
                var admin = Bool()
                userReference.observeSingleEvent(of: .value, with: { (snapshot) in
                    if !snapshot.exists() { return }
                    admin = snapshot.childSnapshot(forPath: "admin").value as! Bool
                    print("USER IS ADMIN: \(admin)")
                    if (admin){
                        try! Auth.auth().signOut()
                        print("Signed user out")
                    } else {
//                        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "mainViewController") as UIViewController
//                        self.window = UIWindow(frame: UIScreen.main.bounds)
//                        self.window?.rootViewController = initialViewControlleripad
//                        self.window?.makeKeyAndVisible()
                    }
                })
            } else {
                print("NO USER IS SIGNED IN")
                // No user is signed in.
            }
        }
    }
    
    func saveStripeId(){
        let ref = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        let userID = Auth.auth().currentUser?.uid
        let userReference = ref.child("user").child(userID!)
        userReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
                let stripe_id = snapshot.childSnapshot(forPath: "stripe_id").value as! String
                UserDefaults.standard.set(stripe_id, forKey: "stripe_id")
                self.doSegue()
            }
        )
    }
    
    @IBAction func continueWithoutSignIn(_ sender: Any) {
        let ref = Database.database().reference(fromURL: "https://vzladreams.firebaseio.com/")
        Auth.auth().signInAnonymously { (user, error) in
            if let error = error {
                print("Sign in failed:", error.localizedDescription)
                
            } else {
                print ("Signed in with uid:", user!.uid)
                let values = ["registration_type": "anonymous", "admin": false, "email": "temp@email.com"] as [String : Any]
                let usersReference = ref.child("user").child(user!.uid)
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    if (err != nil){
                        print(err ?? "")
                        return
                    }
                    print("Saves user succesfully into db")
                    self.doSegue()
                })
            }
        }
    }
    
    func doSegue(){
        self.performSegue(withIdentifier: "redirectAfterLoginFB", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

