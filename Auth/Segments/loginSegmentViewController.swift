//
//  loginSegmentViewController.swift
//  Auth
//
//  Created by Matthew Morikan on 2024-04-08.
//

import UIKit
import Amplify


class loginSegmentViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.addBottomBorderWithColor(color: UIColor.lightGray, width: 0.5)
        passwordTextField.addBottomBorderWithColor(color: UIColor.lightGray, width: 0.5)
        
        self.emailTextField.addPaddingToTextField()
        self.passwordTextField.addPaddingToTextField()
        
        passwordTextField.isSecureTextEntry = true 
    }
    
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Username / password cannot be empty")
            return
        }
        
//        Amplify.Auth.signIn(username: email, password: password) { result in
//            switch result {
//            case .success:
//                print("Sign in successful")
//                DispatchQueue.main.async {
//                }
//            case .failure(let error):
//                print("Sign in failed \(error)")
//            }
//        }
    }
}

extension UIView {
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width,
                              width: self.frame.size.width - 25, height: width)
        self.layer.addSublayer(border)
    }
}

extension UITextField {
    func addPaddingToTextField() {
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
