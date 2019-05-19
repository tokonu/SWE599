//
//  GroupVc.swift
//  swe599
//
//  Created by Onur on 14.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import UIKit

class GroupVc: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = group.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(self.leaveTapped))
        getPosts()
        tableView.reloadData()
    }
    
    @IBAction func createPostTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreatePostVc") as! CreatePostVc
        vc.group = self.group
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func leaveTapped(){
        self.showActivityIndicator()
        Group.leave(group: group) { (res) in
            self.hideActivityIndicator()
            switch res{
            case .success(_):
                Delay.onMain(secs: 0, callback: {
                    AuthManager.currentUser?.remove(group: self.group)
                    self.navigationController?.popViewController(animated: true)
                })
            case .failure(let err):
                self.presentAlert(message: err.message)
            }
        }
    }
    
    func getPosts(){
        self.showActivityIndicator()
        Post.list(for: group) { (result) in
            self.hideActivityIndicator()
            switch result {
            case .success(let posts):
                self.group.setPosts(posts: posts)
                Delay.onMain(secs: 0, callback: self.tableView.reloadData)
            case .failure(let error):
                self.presentAlert(message: error.message)
            }
        }
    }
    
    // TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PostCell
        cell.update(for: group.posts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PostVc") as! PostVc
        vc.post = group.posts[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

class PostCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    func update(for post: Post){
        title.text = post.title
        descriptionLabel.text = post.description
    }
}
