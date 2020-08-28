//
//  ThirdViewController.swift
//  Voter
//
//  Created by Alex Garlock on 11/19/16.
//  Copyright © 2016 Alex Garlock. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseInstanceID

class ThirdViewController: UIViewController {
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        
    }

    
    //Logout of firebase and facebook
    @IBAction func Logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
        } catch let signOutError as NSError{
            print ("Error signing out: %@", signOutError)
        }
        
    }
}
