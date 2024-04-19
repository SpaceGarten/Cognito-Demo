//
//  ViewController.swift
//  Auth
//
//  Created by Matthew Morikan on 2024-04-08.
//

import UIKit
import Amplify
import AuthenticationServices

class ViewController: UIViewController {
    
    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    @IBOutlet weak var loginSegmentView: UIView!
    @IBOutlet weak var registerSegmentView: UIView!
    
    @IBOutlet weak var appleSignInButton: UIButton!
    @IBOutlet weak var googleSignInButton: UIButton!
    
    @IBOutlet weak var ssoSignInStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentOutlet.setTitleTextAttributes(titleTextAttributes, for: .normal)
        self.view.bringSubviewToFront(registerSegmentView)
        
    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.view.bringSubviewToFront(registerSegmentView)
        case 1:
            self.view.bringSubviewToFront(loginSegmentView)
        default:
            break
        }
    }
    
    
    @IBAction func appleSIgnInTapped(_ sender: Any) {
        ssoSignInStatusLabel.text = ""
        ssoSignInStatusLabel.isHidden = true
        
        startSignInWithAppleFlow()
    }
    
    private func startSignInWithAppleFlow() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
}

extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            let userEmail = appleIDCredential.email
            let userGivenName = appleIDCredential.fullName?.givenName
            let userFamilyName = appleIDCredential.fullName?.familyName
            
            DispatchQueue.main.async {
                self.ssoSignInStatusLabel.text = "Sign in successful!"
                self.ssoSignInStatusLabel.textColor = .green
                self.ssoSignInStatusLabel.isHidden = false
            }
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
        self.ssoSignInStatusLabel.text = "Sign in with Apple failed: \(error.localizedDescription)"
        self.ssoSignInStatusLabel.textColor = .red
        self.ssoSignInStatusLabel.isHidden = false
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
