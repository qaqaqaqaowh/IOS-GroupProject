//
//  SignUpViewController.swift
//  Fakestagram
//
// //  Created by Jacob Schantz on 11/4/17.
//  Copyright © 2017 Jacob Schantz. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text
            else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let validError = error {
                self.alert(title: "Error", message: validError.localizedDescription)
            }
            
            if let _ = user {
                NotificationCenter.appLogin()
            }
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func makeRound(_ view: UIView){
        view.layer.cornerRadius = 5
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 255/255, green: 70/255, blue: 80/255, alpha: 1)
        makeRound(emailTextField)
        makeRound(passwordTextField)
        makeRound(loginButton)
        makeRound(signUpButton)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
}
