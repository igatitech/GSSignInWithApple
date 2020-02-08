//
//  StringConstant.swift
//  GSSignInWithApple
//
//  Created by Gati on 02/08/19.
//  Copyright © 2019 iGatiTech. All rights reserved.
//

import Foundation

struct StringConstant {
    //MARK:- COMMON Strings
    struct Common {
        static let kSomethingWrong = "Something went wrong, please try again after some time"
        static let kOk = "OK"
        static let kBack = "Back"
        static let kCancel = "Cancel"
    }
}

extension StringConstant {
    struct Validations {
        static let enterEmail = "Please enter your Email."
        static let enterPwd = "Please enter your Password."
        static let validPwd = "Password must contain at least 8 password characters."
        static let notValidEmail = "Please enter valid Email."
    }
}
