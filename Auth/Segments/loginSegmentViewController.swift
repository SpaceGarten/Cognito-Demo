//
//  loginSegmentViewController.swift
//  Auth
//
//  Created by Matthew Morikan on 2024-04-08.
//

import UIKit
import Amplify
import AWSPluginsCore

class loginSegmentViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var anonSignInButton: UIButton!
    
    @IBOutlet weak var userStatusLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTextFields()
        userStatusLabel.isHidden = true
        signOutButton.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkSignedInStatus()
    }
    
    // MARK: - Actions
    @IBAction func signInButtonTapped(_ sender: Any) {
        signInUser()
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        signOutUser()
    }
    
    @IBAction func anonSignInButtonTapped(_ sender: Any) {
        Task {
            let result = await fetchAuthSession()
            DispatchQueue.main.async {
                switch result {
                case .success(let session):
                    if !session.isSignedIn {
                        self.userStatusLabel.text = "Anon session active."
                    } else {
                        self.userStatusLabel.text = "User is signed in."
                    }
                    self.userStatusLabel.isHidden = false
                    self.signOutButton.isHidden = session.isSignedIn
                case .failure(let error):
                    self.userStatusLabel.text = "Fetch session failed with error \(error)"
                    self.userStatusLabel.isHidden = false
                }
            }
        }
    }

    private func fetchAuthSession() async -> Result<AuthSession, AuthError> {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            return .success(session)
        } catch {
            return .failure(error as? AuthError ?? .unknown("Unexpected error occurred"))
        }
    }

    // MARK: - Private Methods
    private func setUpTextFields() {
        emailTextField.addBottomBorderWithColor(color: UIColor.lightGray, width: 0.5)
        passwordTextField.addBottomBorderWithColor(color: UIColor.lightGray, width: 0.5)
        emailTextField.addPaddingToTextField()
        passwordTextField.addPaddingToTextField()
        passwordTextField.isSecureTextEntry = true
    }
    
    
    
    private func checkSignedInStatus() {
        Task {
            do {
                let isSignedIn = try await Amplify.Auth.fetchAuthSession().isSignedIn
                DispatchQueue.main.async {
                    if isSignedIn {
                        self.userStatusLabel.text = "Already signed in."
                        self.userStatusLabel.isHidden = false
                        self.signOutButton.isHidden = false
                    } else {
                        self.userStatusLabel.text = "Please sign in."
                        self.userStatusLabel.isHidden = false
                        self.signOutButton.isHidden = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.userStatusLabel.text = "Error checking sign in status: \(error.localizedDescription)"
                    self.userStatusLabel.isHidden = false
                }
            }
        }
    }
    
    private func signInUser() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            self.userStatusLabel.text = "Username / password cannot be empty"
            self.userStatusLabel.isHidden = false
            return
        }
        
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
        DispatchQueue.main.async {
            if result.isSignedIn {
                self.userStatusLabel.text = "Signed in successfully."
                self.userStatusLabel.isHidden = false
                self.signOutButton.isHidden = false
            } else {
                self.userStatusLabel.text = "Additional steps required to complete sign in."
                self.userStatusLabel.isHidden = false
            }
            self.signInButton.isEnabled = true
        }
    }
    
    private func handleSignInError(_ error: Error) {
        self.userStatusLabel.text = "Sign in failed: \(error.localizedDescription)"
        self.userStatusLabel.isHidden = false
    }
    
    private func signOutUser() {
        Task {
            _ = await Amplify.Auth.signOut()
            DispatchQueue.main.async {
                self.userStatusLabel.text = "Signed out."
                self.signOutButton.isHidden = true
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
