//
//  SignUpViewController.swift
//  Fakestagram
//
// //  Created by Jacob Schantz on 11/4/17.
//  Copyright © 2017 Jacob Schantz. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: AuthLayout {
    
    
    var emailTextField : UITextField = UITextField()
    var passwordTextField : UITextField = UITextField()
    var loginButton : UIButton = UIButton(){
        didSet{
            loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        }
    }
    var signUpButton : UIButton = UIButton(){
        didSet{
            signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        }
    }
    
    
    @objc func loginButtonTapped() {
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
    
    
    @objc func signUpButtonTapped(){
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        createStackView()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    
    func createLoginViews() {
        emailTextField = createEmailTextField()
        passwordTextField = createPasswordTextField()
        loginButton = createLoginButton()
        signUpButton = createSignUpButton()
    }
    
    
    func createStackView(){
        createLoginViews()
        let loginViews : [UIView] = [emailTextField, passwordTextField, loginButton, signUpButton]
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
