//
//  CreatePostVc.swift
//  swe599
//
//  Created by Onur on 14.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import UIKit

class CreatePostVc: UIViewController {
    @IBOutlet var titleField: UITextField!
    @IBOutlet var descView: UITextView!
    var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "CreatePost"
        descView.layer.borderWidth = 1
        descView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        descView.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    @IBAction func sendTapped(_ sender: Any) {
        guard let title = titleField.text, title != "" else {
            self.presentAlert(message: "Please enter title")
            return
        }
        guard let description = descView.text, description != "" else {
            self.presentAlert(message: "Please enter description")
            return
        }
        self.showActivityIndicator()
        Post.create(title: title, description: description, groupId: group.id) { (result) in
            self.hideActivityIndicator()
            switch result{
            case .success(let post):
                self.group.add(post: post)
                Delay.onMain(secs: 0, callback: {
                    self.navigationController?.popViewController(animated: true)
                })
                break
            case .failure(let error):
                self.presentAlert(message: error.message)
            }
        }
    }
}
