//
//  ViewController.swift
//  swe599
//
//  Created by Onur on 11.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import UIKit

class NavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = IntermediateVc()
        self.pushViewController(vc, animated: false)
    }
    
}

class IntermediateVc: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        connect()
    }
    
    func connect(){
        if AuthManager.isLoggedIn() {
            self.showActivityIndicator()
            AuthManager.getMe { (result) in
                self.hideActivityIndicator()
                switch result {
                case .success(_):
                    Delay.onMain(secs: 0, callback: {
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVc") as! HomeVc
                        self.navigationController?.pushViewController(vc, animated: false)
                        Socket.init_socket()
                    })
                case .failure(let err):
                    self.presentAlert(message: err.message)
                }
            }
        }else{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVc") as! LoginVc
            self.present(vc, animated: false, completion: nil)
        }
    }
}

