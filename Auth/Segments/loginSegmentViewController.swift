//
//  loginSegmentViewController.swift
//  Auth
//
//  Created by Matthew Morikan on 2024-04-08.
//

import UIKit
import Amplify

class loginSegmentViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    @IBOutlet weak var anonSignInButton: UIButton!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTextFields()
        hideSignInStatusLabel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkSignedInStatus()
    }

    // MARK: - Actions
    @IBAction func signInButtonTapped(_ sender: Any) {
        signInUser()
    }

    // MARK: - Private Methods
    private func setUpTextFields() {
        emailTextField.addBottomBorderWithColor(color: UIColor.lightGray, width: 0.5)
        passwordTextField.addBottomBorderWithColor(color: UIColor.lightGray, width: 0.5)
        emailTextField.addPaddingToTextField()
        passwordTextField.addPaddingToTextField()
        passwordTextField.isSecureTextEntry = true
    }

    private func hideSignInStatusLabel() {
//        signInStatusLabel.isHidden = true
    }

    
    private func checkSignedInStatus() {
        Task {
            do {
                let isSignedIn = try await Amplify.Auth.fetchAuthSession().isSignedIn
                if isSignedIn {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showSignedInScreenSegue", sender: self)
                    }
                } else {
                    DispatchQueue.main.async {
//                        self.signInStatusLabel.text = "Please sign in."
//                        self.signInStatusLabel.isHidden = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
//                    self.signInStatusLabel.text = "Error checking sign in status"
//                    self.signInStatusLabel.isHidden = false
                }
            }
        }
    }

    private func signInUser() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Username / password cannot be empty")
            return
        }

        // Disable the sign-in button to prevent multiple taps.
        signInButton.isEnabled = false

        Task {
            do {
                let signInResult = try await Amplify.Auth.signIn(username: email, password: password)
                DispatchQueue.main.async {
                    self.handleSignInResult(signInResult)
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleSignInError(error)
                }
            }

            // Re-enable the sign-in button.
            DispatchQueue.main.async {
                self.signInButton.isEnabled = true
            }
        }
    }

    private func handleSignInResult(_ result: AuthSignInResult) {
        if result.isSignedIn {
            print("Sign in successful: \(result)")
            performSegue(withIdentifier: "showSignedInScreenSegue", sender: self)
        } else {
            // Handle other sign-in steps if necessary.
        }
    }

    private func handleSignInError(_ error: Error) {
        print("Sign in failed with error \(error)")
//        signInStatusLabel.text = "Sign in failed"
//        signInStatusLabel.isHidden = false
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
