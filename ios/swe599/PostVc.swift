//
//  PostVc.swift
//  swe599
//
//  Created by Onur on 15.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import UIKit

class PostVc: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageView: UITextView!
    
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.hideKeyboardWhenTappedAround()
        messageView.delegate = self
        messageView.layer.borderWidth = 1
        messageView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        messageView.layer.cornerRadius = 5
        messageView.text = ""
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tableViewTappedd))
        tableView.addGestureRecognizer(tap)
        
        titleLabel.text = post.title
        descriptionLabel.text = post.description
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        Socket.shared.joinPost(postId: post.id) {[weak self] (message) in
            self?.post.add(message: message)
            Delay.onMain(secs: 0, callback: {
                self?.reloadTableview()
            })
        }
        getMessages()
    }
    
    @objc func tableViewTappedd(){
        messageView.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Socket.shared.leavePost(postId: post.id)
    }
    
    private func getMessages(){
        self.showActivityIndicator()
        Post.getMessages(for: post) { (result) in
            self.hideActivityIndicator()
            switch result {
            case .success(let messages):
                self.post.set(messages: messages)
                self.reloadTableview()
            case .failure(let error):
                self.presentAlert(message: error.message)
            }
        }
    }
    
    func reloadTableview(){
        Delay.onMain(secs: 0) {
            self.tableView.reloadData()
            if self.post.messages.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: self.post.messages.count-1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let text = messageView.text, text != "" else { return }
        Socket.shared.sendMessage(text: text, postId: post.id)
        messageView.text = ""
    }
    
    func textViewDidChange(_ textView: UITextView) {
        return
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = post.messages[indexPath.row].text
        return cell
    }
}
