//
//  RegisterViewController.swift
//  WatchBox
//
//  Created by Iyinoluwa Tugbobo on 3/28/23.
//

import UIKit
import FirebaseAuth

private let reuseIdentifier = "Cell"

class RegisterViewController: UIViewController {


    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var errorIndicator: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showError(with: String) {
        errorIndicator.text = with
    }
    
    @IBAction func handleRegister(_ sender: Any) {
        errorIndicator.text = ""
        guard
            let email = emailField.text,
            let password = passwordField.text,
            let confirm = confirmField.text
        else {return}
        
        if (email == "" || password == "" || confirm == "" ) {
            showError(with: "One or more fields blank cannot be left blank!")
            return
        }
        
        // Check if username is taken
        
        if (password != confirm) {
            showError(with: "Both password fields must match!")
            return
        }
        
        activityIndicator.startAnimating()
        Auth.auth().createUser(withEmail: email, password: password) {res, err in
            guard (res?.user) != nil else {
                self.showError(with: err!.localizedDescription)
                self.activityIndicator.stopAnimating()
                return
            }
            self.performSegue(withIdentifier: "showHome", sender: nil)            
        }
    }
}
