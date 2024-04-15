//
//  ViewController.swift
//  Auth
//
//  Created by Matthew Morikan on 2024-04-08.
//

import UIKit
import Amplify

class ViewController: UIViewController {

    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    @IBOutlet weak var loginSegmentView: UIView!
    @IBOutlet weak var registerSegmentView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentOutlet.setTitleTextAttributes(titleTextAttributes, for: .normal)
        self.view.bringSubviewToFront(registerSegmentView)
        
//        // Check if user is signed in
//        Amplify.Auth.fetchAuthSession { result in
//            switch result {
//            case .success(let session):
//                if session.isSignedIn {
//                    // Direct the user to the main part of your application
//                } else {
//                    // Show the login screen
//                }
//            case .failure(let error):
//                print("Fetch session failed with error \(error)")
//            }
//        }
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
    
}

