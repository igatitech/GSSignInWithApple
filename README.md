# GSSignInWithApple

Apple has introduced a tremendously new way to sign in to apps using their Apple ID. This project has complete implementation of **Sign In with Apple** functionality.

> Interestingly, if your app is using any third-party Sign-In service(e.g. Facebook, Google, Twitter, LinkedIn) to authenticate users must also offer Sign-In with Apple as an equivalent option.

![alt text](https://github.com/igatitech/GSSqliteGlobal/blob/master/Resources/SignInWithApple.png)

**@Note:** There is a high chance Apple may reject your app if you are using
third party SignIn options and not using SignIn with Apple option.

AppStore Review Guidelines: [SignIn with Apple](https://developer.apple.com/app-store/review/guidelines/#sign-in-with-apple)

## Sign In with Apple Developer Account set up:

- Create App ID by adding unique bundle identifier
(com.iGatiTech.GSSignInWithApple) of your application and enable
SignIn with Apple

![alt text](https://github.com/igatitech/GSSqliteGlobal/blob/master/Resources/AppID.png)

 - Generate Certificates and Provisioning profiles
 
 - Open your Xcode Project -> Select the Project Target ->
 Signing -> Capabilities tab
 
- Click on the +(Add) button, type Sign in with apple
 
 - Double-tap or Drag and Drop the sign in with apple to capabilities.
 
 - Setup Team, Provisioning Profile for which you have enabled
 SignIn with Apple on the Apple Developer portal.
 
 ![alt text](https://github.com/igatitech/GSSqliteGlobal/blob/master/Resources/Capability.png)
 
 ## Implementation
 
 AuthenticationServices framework is used to provide users an interface to set up accounts and sign in with their Apple ID. 

- Add a new ```LoginViewController``` class
    - Import ```AuthenticationServices``` framework
    - Add a Sign in with Apple Button([ASAuthorizationAppleIDButton](https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidbutton))
    
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    setUpLoginButtonView()
}

func setUpLoginButtonView() {
    let authorizationButton = ASAuthorizationAppleIDButton()
    authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
    self.loginProviderStackView.addArrangedSubview(authorizationButton)
}
```

![alt text](https://github.com/igatitech/GSSqliteGlobal/blob/master/Resources/Login.png)

- Implement ```handleAuthorizationAppleIDButtonPress``` method. This method will be called when user will tap the **Sign in with Apple** button. It will initialise a controller ```ASAuthorizationController``` to perform the request.

```swift
@objc func handleAuthorizationAppleIDButtonPress() {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
}
```
- The system then checks whether the user is signed in with their Apple ID on the device. If the user is not signed in at the system-level, the app presents an alert directing the user to sign in with their Apple ID in Settings. 

![alt text](https://github.com/igatitech/GSSqliteGlobal/blob/master/Resources/Setting.png)          ![alt text](https://github.com/igatitech/GSSqliteGlobal/blob/master/Resources/SettingSignIn.png)

- Setup presentation context provider.
    - It will present Sign In with Apple action sheet on top of the window.
    
```swift
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {

  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return view.window!
  }
}
```

- Implement ```ASAuthorizationControllerDelegate```

    - If the authentication succeeds, the authorization controller invokes the ```authorizationController(controller:didCompleteWithAuthorization:)``` delegate function, which the app uses to store the user’s data in the keychain.

    - Add [KeyChainItem.Swift](https://github.com/igatitech/GSSignInWithApple/blob/master/GSSignInWithApple/SupportingFiles/KeychainItem.swift) file into your project.
    
    - If the authentication fails, the authorization controller invokes the ```authorizationController(controller:didCompleteWithError:)``` delegate function to handle the error.
```swift
extension LoginViewController: ASAuthorizationControllerDelegate {
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

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}
```

```swift
private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
}
```

> Once the system authenticates the user, the app displays the HomeViewController which shows the user information requested from the framework, including the user-provided full name and email address. The view controller also displays a Sign Out button and stores the user data in the keychain. When the user taps the Sign Out button, the app deletes the user information from the view controller and the keychain, and presents the LoginViewController to the user.

- In ```LoginViewController``` implement ```performExistingAccountSetupFlows()``` function in ```viewDidAppear()``` method to check if the user has an existing account.

```swift
func performExistingAccountSetupFlows() {
    // Prepare requests for both Apple ID and password providers.
    let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                    ASAuthorizationPasswordProvider().createRequest()]
    
    // Create an authorization controller with the given requests.
    let authorizationController = ASAuthorizationController(authorizationRequests: requests)
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
}
```
- Check user credential state in the 
```SceneDelegate.scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)``` function to check the status of the saved user credentials. If the user granted authorization for the app then the app will directly redirect to the  Home Screen.

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
        switch credentialState {
        case .authorized:
            print("Authorized")
            self.pushToHomeScreen()
            break // The Apple ID credential is valid.
        case .revoked, .notFound:
            // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
            print("Not Authorized")
        default:
            break
        }
    }
    guard let _ = (scene as? UIWindowScene) else { return }
}
```

- Create extension of SceneDelegate to write the code for navigation user to Home Screen.

```swift
extension SceneDelegate {
    func pushToHomeScreen() {
        guard let vcHome = GetViewController(StoryBoard: .Main, Identifier: .Home) else {
            return
        }
        let navController = UINavigationController(rootViewController: vcHome)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
}
```

@note: If you are using above lines of code for navigating user to Home screen, you might face error in few lines. In order to resolve that error, please add these folders in your project: [Constant](https://github.com/igatitech/GSSignInWithApple/tree/master/GSSignInWithApple/Global/Constants), [FileResource](https://github.com/igatitech/GSSignInWithApple/tree/master/GSSignInWithApple/Global/FileResource)

## ScreenShots

![alt text](https://github.com/igatitech/GSSqliteGlobal/blob/master/Resources/SignIn1.png)          ![alt text](https://github.com/igatitech/GSSqliteGlobal/blob/master/Resources/SignIn2.png)          ![alt text](https://github.com/igatitech/GSSqliteGlobal/blob/master/Resources/SignIn3.png)          ![alt text](https://github.com/igatitech/GSSqliteGlobal/blob/master/Resources/SignIn4.png)

**Happy Coding! Cheers!!** 🥂 

## Author
If you wish to contact me, email at: [gati1993@gmail.com](gati1993@gmail.com)

## License
Copyright 2020 iGatiTech

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.









    
    







 




