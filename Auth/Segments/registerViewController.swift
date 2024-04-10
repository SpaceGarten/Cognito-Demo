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
    @IBOutlet weak var verifyTextField: UITextField!
    
    private var registeredEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, confirmPassword == password else {
            print("Make sure to fill all fields and that the passwords match")
            return
        }
        
        // Store the email for later use during verification
        self.registeredEmail = email
        
        // Implement sign up logic...
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
                    // Handle success on the main thread if needed
                    DispatchQueue.main.async {
                        // Navigate to the login screen or home screen
                        print("Verification successful: \(result)")
                    }
                } catch {
                    // Handle failure on the main thread if needed
                    DispatchQueue.main.async {
                        // Show error message
                        print("Verification failed with error: \(error)")
                    }
                }
            }
        
    }
    
    
    // Add any additional methods needed for the view controller...
}
