//
//  ViewController.swift
//  Auth
//
//  Created by Matthew Morikan on 2024-04-08.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    @IBOutlet weak var loginSegmentView: UIView!
    @IBOutlet weak var registerSegmentView: UIView!
    
    
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
    
}

