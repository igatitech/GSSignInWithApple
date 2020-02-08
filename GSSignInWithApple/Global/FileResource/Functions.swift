//
//  Functions.swift
//  GSSignInWithApple
//
//  Created by Gati on 02/08/19.
//  Copyright © 2019 iGatiTech. All rights reserved.
//

import Foundation
import UIKit

//MARK:- Get View Controller
func GetViewController(StoryBoard : Storyboards,Identifier : ControllerIdentifier) ->UIViewController?{
    
    return UIStoryboard(name: StoryBoard.rawValue, bundle: nil).instantiateViewController(withIdentifier: Identifier.rawValue)
}
