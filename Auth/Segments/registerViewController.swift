//
//  registerViewController.swift
//  Auth
//
//  Created by Matthew Morikan on 2024-04-08.
//
import UIKit
import Amplify
import AWSCognitoAuthPlugin



class registerViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var verifyTextField: UITextField!
    
    @IBOutlet weak var registerSuccessMessage: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    private var registeredEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialState()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupInitialState() {
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        verifyTextField.isHidden = true
        verifyButton.isHidden = true
        registerSuccessMessage.isHidden = true
        signOutButton.isHidden = true
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty,
              password == confirmPassword else {
            self.registerSuccessMessage.text = "Ensure all fields are filled and passwords match."
            self.registerSuccessMessage.isHidden = false
            return
        }
        
        self.registeredEmail = email
        
        Task {
            do {
                let signUpResult = try await Amplify.Auth.signUp(username: email, password: password)
                DispatchQueue.main.async {
                    if case .confirmUser = signUpResult.nextStep {
                        self.verifyTextField.isHidden = false
                        self.verifyButton.isHidden = false
                        self.registerSuccessMessage.isHidden = true // Hide success message until verified
                    } else {
                        self.registerSuccessMessage.text = "Check your email for verification code"
                        self.registerSuccessMessage.isHidden = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.registerSuccessMessage.text = "Registration failed: \(error.localizedDescription)"
                    self.registerSuccessMessage.isHidden = false
                }
            }
        }
    }
    
    
    @IBAction func verifyEmailButtonTapped(_ sender: UIButton) {
        guard let verificationCode = verifyTextField.text, !verificationCode.isEmpty,
              let email = registeredEmail else {
            registerSuccessMessage.text = "Email or verification code cannot be empty"
            registerSuccessMessage.isHidden = false
            print("Email or verification code cannot be empty")
            return
        }
        
        Task {
            do {
                _ = try await Amplify.Auth.confirmSignUp(for: email, confirmationCode: verificationCode)
                DispatchQueue.main.async {
                    self.handleVerificationSuccess()
                    
                }
            } catch {
                DispatchQueue.main.async {
                    self.registerSuccessMessage.text = "Verification failed: \(error.localizedDescription)"
                    self.registerSuccessMessage.isHidden = false                }
            }
        }
    }
    
    
    @IBAction func signOutTapped(_ sender: Any)   {
        Task {
            _ = await Amplify.Auth.signOut()
            print("Successfully signed out")
            DispatchQueue.main.async { [weak self] in
                self?.registerSuccessMessage.text = "Signed out"
                self?.registerSuccessMessage.isHidden = false
                self?.signOutButton.isHidden = true
                self?.verifyTextField.isHidden = true
                self?.verifyButton.isHidden = true
                // Optionally, reset other UI elements to their default states here
            }
        }
    }
    
    private func handleVerificationSuccess() {
        verifyTextField.isHidden = true
        verifyButton.isHidden = true
        registerSuccessMessage.text = "Verification Successful. Signed In."
        registerSuccessMessage.isHidden = false
        signOutButton.isHidden = false
    }
}
