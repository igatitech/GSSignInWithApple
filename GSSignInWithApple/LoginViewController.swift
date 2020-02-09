//
//  LoginViewController.swift
//  GSSignInWithApple
//
//  Created by Gati on 05/02/20.
//  Copyright © 2020 iGatiTech. All rights reserved.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {
    //MARK:- IBOutlet
    @IBOutlet weak var textFieldEmail : UITextField!
    @IBOutlet weak var textFieldPassword : UITextField!
    @IBOutlet weak var buttonLogin : UIButton!
    @IBOutlet weak var loginProviderStackView: UIStackView!

    //MARK:- View Controller view life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpLoginButtonView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performExistingAccountSetup()
    }
    
    //MARK:- IBActions
    @IBAction func buttonLoginClicked(_ sender : Any) {
        
    }
    
    //MARK:- Custom Methods
    func setUpView() {
        buttonLogin.layer.cornerRadius = 5.0
        buttonLogin.layer.masksToBounds = true
    }
    
    func setUpLoginButtonView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }
    
    func performExistingAccountSetup() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: Bundle.main.bundleIdentifier ?? "", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vcHome = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            vcHome.strUserID = userIdentifier
            vcHome.strGivenName = fullName?.givenName
            vcHome.strFamilyName = fullName?.familyName
            vcHome.strEmail = email
            
            vcHome.modalPresentationStyle = .fullScreen
//            vcHome.isModalInPresentation = true
            
            self.present(vcHome, animated: true, completion: nil)
        }
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- Selector Methods
    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    /// Complete Authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    /// Authorization Error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print(error.localizedDescription)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
