//
//  NicknameViewController.swift
//  VDMChat
//
//  Created by Tuo on 2017-06-12.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

class NicknameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var nickNameInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nickNameInput.delegate = self;
        guard let name = AppManager.sharedInstance.nickname, !name.isEmpty else {
            infoLabel.text = "You don't have nickname yet!"
            return;
        }

        infoLabel.text = "Change your nickname!"
        nickNameInput.text = name;
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let name = textField.text else {
            return;
        }

        UserDefaults.standard.set(name, forKey: "nickname")
        AppManager.sharedInstance.nickname = name;
    }

}
