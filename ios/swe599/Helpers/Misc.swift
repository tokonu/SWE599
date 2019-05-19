//
//  Logger.swift
//  swe599
//
//  Created by Onur on 11.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import UIKit

class Logger {
    static func Log(key: String, message: String){
        print("CustomLog-\(key): \(message)")
    }
}

class Delay {
    static func onMain(secs: Double, callback: @escaping ()->()){
        DispatchQueue.main.asyncAfter(deadline: .now() + secs, execute: callback)
    }
}

struct ErrorWithMessage: Error {
    let message: String
}
typealias AuthError = ErrorWithMessage
typealias InputError = ErrorWithMessage
typealias ApiError = ErrorWithMessage

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showActivityIndicator(){
        Delay.onMain(secs: 0) {
            ActivityIndicator.show(on: self.navigationController?.view ?? self.view)
        }
    }
    
    func hideActivityIndicator(){
        Delay.onMain(secs: 0) {
            ActivityIndicator.hide()
        }
    }
    
    func presentAlert(message: String, title: String = "Error"){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        Delay.onMain(secs: 0) {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
 
