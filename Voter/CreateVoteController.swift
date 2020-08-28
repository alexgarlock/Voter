//
//  CreateVoteController.swift
//  Voter
//
//  Created by Alex Garlock on 6/4/17.
//  Copyright © 2017 SAC Studios, LLC. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseInstanceID
import Darwin


class CreateVoteController: UIViewController {

    @IBOutlet weak var LoadVoterTypes: UIPickerView!
    @IBOutlet weak var ContestName: UITextField!
    @IBOutlet weak var ContestDescription: UITextView!
    @IBOutlet weak var NumberOfUsers: UITextField!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NumberOfUsers.keyboardType = .numberPad
        ref = Database.database().reference()
    }
    
    @IBAction func SubmitContest(_ sender: Any) {
        
//Convert to text
        let contesttitle = ContestName.text;
        let contestdescript = ContestDescription.text;
        let participants = NumberOfUsers.text;
       
//Come back and add restrictions to number of users
        
//Some Firebase Stuff
        let userID = Auth.auth().currentUser?.uid
        let contestRef = ref.child("craftType").child("Custom")
        let thisContest = contestRef.childByAutoId()
        
//Store to firebase
        thisContest.setValue(["ContestName": contesttitle, "ContestDescription": contestdescript, "Participants":participants])
        thisContest.child("User").setValue(userID)
    }

    
//Functions called in this code above
    func displayMyAlertMessage(userMessage:String)
    {
        let myAlert = UIAlertController(title:"Error", message:userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default, handler:nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated:true, completion:nil)
    }
    
    
}
