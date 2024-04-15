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
    
    private var registeredEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        verifyTextField.isHidden = true
        verifyButton.isHidden = true
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              password == confirmPasswordTextField.text else {
            print("Ensure all fields are filled and passwords match.")
            return
        }
        
        registeredEmail = email
        
        Task {
            do {
                let signUpResult = try await Amplify.Auth.signUp(username: email, password: password)
                DispatchQueue.main.async {
                    if case .confirmUser = signUpResult.nextStep {
                        self.verifyTextField.isHidden = false
                        self.verifyButton.isHidden = false
                        
                    } else if case .done = signUpResult.nextStep {
                    } else {
                    }
                }
            } catch {
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
}
