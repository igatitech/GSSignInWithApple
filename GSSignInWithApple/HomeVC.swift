//
//  HomeVC.swift
//  GSSignInWithApple
//
//  Created by Gati on 05/02/20.
//  Copyright © 2020 iGatiTech. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    //MARK:- Outlets
    @IBOutlet weak var labelUserID: UILabel!
    @IBOutlet weak var labelGivenName: UILabel!
    @IBOutlet weak var labelFamilyname: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var buttonSignOut: UIButton!
    
    //MARK:- Variables
    var strUserID, strGivenName, strFamilyName, strEmail : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Custom Methods
    func setUpView() {
        buttonSignOut.layer.cornerRadius = 5.0
        buttonSignOut.layer.masksToBounds = true
        labelUserID.text = KeychainItem.currentUserIdentifier
        labelGivenName.text = strGivenName
        labelFamilyname.text = strFamilyName
        labelEmail.text = strEmail
    }
    
    //MARK:- IBActions
    @IBAction func buttonSignOutClicked(_ sender : Any) {
        // For the purpose of this demo app, delete the user identifier that was previously stored in the keychain.
        KeychainItem.deleteUserIdentifierFromKeychain()
        
        // Clear the user interface.
        labelUserID.text = ""
        labelGivenName.text = ""
        labelFamilyname.text = ""
        labelEmail.text = ""
        
        // Display the login controller again.
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion : nil)
        }
    }

}
