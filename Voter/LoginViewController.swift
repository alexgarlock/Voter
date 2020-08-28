//
//  LoginViewController.swift
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

class LoginViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
// Check if already logged in. --------------------------------
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                //then move to main screen since logged in
                let viewController = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as UIViewController
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
//end of view did load.
    
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
                    print("Failed to gather user info", err ?? "")
                    return
                }

                //then move to main screen since logged in
                let viewController = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as UIViewController
                self.present(viewController, animated: true, completion: nil)
        }
        
    }
    
//end of facebook login.-----------------------------------------------------
    
//manual login with email----------------------------------------------------
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var userFullName: UITextField!
    
    
    @IBAction func registerButton(_ sender: Any) {
        let name = userFullName.text;
        let email = userEmailTextField.text;
        let password = userPasswordTextField.text;
        let RePassword = repeatPasswordTextField.text;
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: email!)
        let letters = CharacterSet.alphanumerics
        
        //check for empty fields
        if(name!.isEmpty || email!.isEmpty || password!.isEmpty || (RePassword!.isEmpty))
        {
            //Display alert message
            displayMyAlertMessage(userMessage: "All Fields are required.")
            
            return
        }
        //check if username is long enough.
        if ((name?.characters.count)! < 6){
            displayMyAlertMessage(userMessage: "Username is too short. Please enter a Username longer than six characters.")
            return
        }
        
        //check if username contains letters
        if (name!.trimmingCharacters(in: letters) != "") {
            displayMyAlertMessage(userMessage: "Invalid characters in UserName. Please use only letters and numbers.")
        }
        
        //Check if password length is correct.
        if ((password?.characters.count)! < 6){
            displayMyAlertMessage(userMessage: "Password is too short. Pleaes enter a password longer than six characters.")
            return
        }
        
        //Check if email is correctly entered
        if isEmailAddressValid
        {
            //email vaild cont.
        } else {
            displayMyAlertMessage(userMessage: "Email is not valid. ")
        }
        
        //Check if passwords match
        if(password != RePassword)
        {
            //Display an alert message
            displayMyAlertMessage(userMessage: "Passwords do not match.")
            
            return
        }
        
        //Store data locally
        UserDefaults.standard.set(name, forKey:"name")
        UserDefaults.standard.set(email, forKey:"email")
        UserDefaults.standard.set(password, forKey:"password")
        UserDefaults.standard.synchronize()

        //add user to firebase. Check if user already exists
       Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
    
            if error?._code == (AuthErrorCode.internalError.rawValue)
                {
                }else{
                     self.displayMyAlertMessage(userMessage: "Email already in use. Please see the login page.")
                }
            }
    
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                var ref: DatabaseReference!
                ref = Database.database().reference()
                ref.child("users")
                    .queryOrdered(byChild: "username")
                    .queryEqual(toValue: name?.uppercased())
                    .observeSingleEvent(of: .value, with: { snapshot in
                        if !snapshot.exists(){
                            //add email to database
                            var ref: DatabaseReference!
                            ref = Database.database().reference()
                            ref.child("users").child((user?.uid)!).setValue(["username": email])
                        }
                    }) { error in
                        print(error.localizedDescription)
                }
            }
        }
    }
    
    
// --------------------------------------------funcs that are called above this line -----------------------------------------------
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
 
    
    func displayMyAlertMessage(userMessage:String)
    {
        let myAlert = UIAlertController(title:"Error", message:userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default, handler:nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated:true, completion:nil)
    }
    
}
