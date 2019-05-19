//
//  LoginVc.swift
//  swe599
//
//  Created by Onur on 11.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import UIKit

protocol LoginVcDelegate: UIViewController {
    func didDismissAfterLogin()
}

private struct LoginCreds {
    let email: String
    let password: String
}


class LoginVc: UIViewController {
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    
    weak var delegate: LoginVcDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let creds = getLoginCredsOrShowError() else {
            return
        }
        self.showActivityIndicator()
        AuthManager.login(email: creds.email, password: creds.password) { [weak self] (errorMessage) in
            self?.hideActivityIndicator()
            if let error = errorMessage {
                self?.presentAlert(message: error)
            } else {
                self?.authSuccess()
            }
            self?.loginButton.isEnabled = true
        }
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        guard let creds = getLoginCredsOrShowError() else {
            return
        }
        self.showActivityIndicator()
        AuthManager.signup(email: creds.email, password: creds.password) { [weak self] (errorMessage) in
            self?.hideActivityIndicator()
            if let error = errorMessage {
                self?.presentAlert(message: error)
            } else {
                self?.authSuccess()
            }
            self?.loginButton.isEnabled = true
        }
    }
    
    private func authSuccess(){
        Delay.onMain(secs: 0) {
            self.dismiss(animated: true) {
                self.delegate?.didDismissAfterLogin()
            }
        }
    }
    
    private func getLoginCredsOrShowError() -> LoginCreds? {
        let res = getLoginCreds()
        switch res {
        case .success(let c):
            return c
        case .failure(let e):
            self.presentAlert(message: e.message)
            return nil
        }
    }
    
    private func getLoginCreds() -> Result<LoginCreds, InputError> {
        guard let email = emailField.text, email != "" else {
            return .failure(InputError(message: "Please enter email"))
        }
        guard let password = passwordField.text, password != "" else {
            return .failure(InputError(message: "Please enter password"))
        }
        return .success(LoginCreds(email: email, password: password))
    }
    
}
