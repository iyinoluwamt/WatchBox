//
//  ViewController.swift
//  WatchBox
//
//  Created by Iyinoluwa Tugbobo on 3/15/23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class AuthViewController: UIViewController {
    
    /// IBOutlets
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var errorIndicator: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    /// Structures
    
    let auth = Auth.auth()
    
    /// VC Init
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.stopAnimating()
        emailField.text = ""
        passwordField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    /// VC Functions
    
    func showError(with: String) {
        errorIndicator.text = with
    }

    /// IBActions
    
    @IBAction func loginWithUsername(_ sender: Any) {
        
        guard
            let email = emailField.text,
            let password = passwordField.text
        else {
            showError(with: "Error retrieving string from field")
            return
        }
        
        guard
            email != "",
            password != ""
        else {
            showError(with:"Username/password field cannot be blank")
            return
        }
        
        activityIndicator.startAnimating()
        errorIndicator.text = ""
        auth.signIn(withEmail: email, password: password) { [weak self] res, err in
            guard res != nil else {
                self?.showError(with: err?.localizedDescription ?? "Unknown sign in error.")
                self?.activityIndicator.stopAnimating()
                return
            }
            self?.navigationController?.popViewController(animated: true)
        }

    }
    
    @IBAction func signUpWithGoogle(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard
                error == nil
            else {
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
              return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            activityIndicator.startAnimating()
            Auth.auth().signIn(with: credential) { result, error in
                guard (result?.user) != nil else {
                    print(error!)
                    self.activityIndicator.stopAnimating()
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    @IBAction func signUpWithTwitter(_ sender: Any) {
        
    }
    
}

