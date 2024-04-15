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
    
    @IBOutlet weak var signInStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.addBottomBorderWithColor(color: UIColor.lightGray, width: 0.5)
        passwordTextField.addBottomBorderWithColor(color: UIColor.lightGray, width: 0.5)
        
        self.emailTextField.addPaddingToTextField()
        self.passwordTextField.addPaddingToTextField()
        
        passwordTextField.isSecureTextEntry = true
        signInStatusLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            Task {
                let isSignedIn = try await Amplify.Auth.fetchAuthSession().isSignedIn
                if isSignedIn {
                    // Perform the segue to the "Signed In" screen
                    performSegue(withIdentifier: "showSignedInScreenSegue", sender: self)
                } else {
                    // If not signed in, possibly update the UI or do nothing
                    signInStatusLabel.text = "Please sign in."
                }
            }
        }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Username / password cannot be empty")
            return
        }
        Task {
            do {
                let signInResult = try await Amplify.Auth.signIn(username: email, password: password)
                DispatchQueue.main.async {
                    // Handle successful sign-in
                    print("Sign in successful: \(signInResult)")
                    // Perform action on success, such as transitioning to another view controller
                }
            } catch {
                DispatchQueue.main.async {
                    // Handle error on sign-in
                    print("Sign in failed with error \(error)")
                }
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await Amplify.Auth.signOut()
                DispatchQueue.main.async {
                    // Update the UI to reflect the user is not signed in
                    self.updateSignInStatus()
                }
            } catch {
                DispatchQueue.main.async {
                    // Handle sign-out error
                    print("Error signing out: \(error)")
                }
            }
        }
    }
    
    func updateSignInStatus() {
        Task {
            do {
                // Try to get the current user asynchronously and handle possible errors.
                let user = try await Amplify.Auth.fetchAuthSession()
                DispatchQueue.main.async {
                    // If the fetchAuthSession does not throw, it means the function call was successful.
                    if user.isSignedIn {
                        self.signInStatusLabel.text = "User is signed in"
                        self.signInStatusLabel.isHidden = false
                    } else {
                        self.signInStatusLabel.text = "User is not signed in"
                        self.signInStatusLabel.isHidden = false
                    }
                }
            } catch {
                // Handle the error that `fetchAuthSession` might throw.
                DispatchQueue.main.async {
                    self.signInStatusLabel.text = "Failed to fetch sign-in status"
                    self.signInStatusLabel.isHidden = false
                }
            }
        }
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
