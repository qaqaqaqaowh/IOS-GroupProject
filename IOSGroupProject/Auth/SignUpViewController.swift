//
//  SignUpViewController.swift
//  Fakestagram
//
//  Created by Jacob Schantz on 11/4/17.
//  Copyright © 2017 Jacob Schantz. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class SignUpViewController : UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let ref = Database.database().reference()
        
        guard let email = emailTextField.text,
            let password = passwordTextField.text
            else{return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let validError = error {
                self.alert(title: "error", message: validError.localizedDescription)
            }
            if let validUser = user{
                self.navigationController?.popViewController(animated: true)
                let uid = validUser.uid
                let userEmail : [String:Any] = ["email": email]
                ref.child("users").child(uid).setValue(userEmail)
            }
        }
    }
  
    
    func makeRound(_ view: UIView){
        view.layer.cornerRadius = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 255/255, green: 70/255, blue: 80/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        makeRound(emailTextField)
        makeRound(passwordTextField)
        makeRound(signUpButton)
    }
    
}


extension SignUpViewController {

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
}


