//
//  AHCViewController.swift
//  Voter
//
//  Created by Server on 12/4/16.
//  Copyright © 2016 SAC Studios, LLC. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseInstanceID


class AHCViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener() { auth, user in
         
            if user != nil {
            
                //then move to main screen since logged in
                let viewController = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as UIViewController
                self.present(viewController, animated: true, completion: nil)
            }
        }
    
        
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions:["email","public_profile"], from: self) {
            loginResult,error in
            self.ShowEmailAddress()
        }
    }
    
    func ShowEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else
        {return}
        
        let credentials =
            FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials, completion:
            {
                (user, error) in
                if error != nil
                {
                    print("Something went wrong with our loging", error ?? "")
                    return
                }
                print("Sucessfully logged in with:", user ?? "")
        })
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start
            {
                (connection, result, err) in
                
                if err != nil
                {
                    print("Failed to start graph request", err ?? "")
                    return
                }
                print(result ?? "")
                
                //then move to main screen since logged in
                let viewController = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as UIViewController
                self.present(viewController, animated: true, completion: nil)
        }
        
    }
    
    //manual login with email-----------------------------------
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    //add forgot password click
    @IBAction func ForgotPassword(_ sender: Any) {
        let userInput = userEmailTextField.text;
        Auth.auth().sendPasswordReset(withEmail: userInput!) { (error) in
        }
        
        if(userInput!.isEmpty)
        {
            //Display alert message enter email above
            self.displayMyAlertMessage(userMessage: "Please enter email above.")
        }
        //Display alert message email sent
        displayMyAlertMessage(userMessage: "You will get an email shortly.")
    }

    @IBAction func AHCButton(_ sender: Any) {
        let email = userEmailTextField.text;
        let password = userPasswordTextField.text;
        
        //check for empty fields
        if(email!.isEmpty || password!.isEmpty)
        {
            //Display alert message
            displayMyAlertMessage(userMessage: "All Fields are required")
            
            return
        }

        //Check if email has @ ALEX COME BACK!

        //Store data
        UserDefaults.standard.set(email, forKey:"email")
        UserDefaults.standard.set(password, forKey:"password")
        UserDefaults.standard.synchronize()
        
        
        //Authenticate user to firebase
        Auth.auth().signIn(withEmail: self.userEmailTextField.text!, password: self.userPasswordTextField.text!) {(error) in
            //Display alert message
            self.displayMyAlertMessage(userMessage: "Wrong email or password")
        }

    }
    
    func displayMyAlertMessage(userMessage:String)
    {
        let myAlert = UIAlertController(title:"Alert", message:userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default, handler:nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated:true, completion:nil)
    }

    
}
