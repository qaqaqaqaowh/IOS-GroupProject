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


class SignUpViewController : AuthLayout {
    
    var emailTextField : UITextField = UITextField()
    var passwordTextField : UITextField = UITextField()
    var signUpButton : UIButton = UIButton(){
        didSet{
            signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        }
    }
    @objc func signUpButtonTapped(){
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        createStackView()
    }
    
}



extension SignUpViewController {
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    
    func createLoginViews() {
        emailTextField = createEmailTextField()
        passwordTextField = createPasswordTextField()
        signUpButton = createSignUpButton()
    }
    
    
    func createStackView(){
        createLoginViews()
        let loginViews : [UIView] = [emailTextField, passwordTextField, signUpButton]
        var loginStackView = UIStackView()
        loginStackView = UIStackView(arrangedSubviews: loginViews)
        loginStackView.axis = .vertical
        loginStackView.distribution = .fillEqually
        loginStackView.alignment = .center
        loginStackView.spacing = 50
        loginStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginStackView)
        loginStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
}


