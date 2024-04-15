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
            print("Email or verification code cannot be empty")
            return
        }
        
        Task {
            do {
                let result = try await Amplify.Auth.confirmSignUp(for: email, confirmationCode: verificationCode)
                DispatchQueue.main.async {
                    print("Verification successful: \(result)")
                }
            } catch {
                DispatchQueue.main.async {
                    print("Verification failed with error: \(error)")
                }
            }
        }
    }
    
    
    @IBAction func signOutTapped(_ sender: Any)  {
        Task {
            await Amplify.Auth.signOut()
            print("Successfully signed out")
            DispatchQueue.main.async { [weak self] in
                self?.registerSuccessMessage.text = "Signed out"
                self?.signOutButton.isHidden = true
                // Optionally, you might want to navigate back to the sign-in screen.
            }
        }
    }
}
