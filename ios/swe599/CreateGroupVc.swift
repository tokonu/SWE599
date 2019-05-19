//
//  CreateGroupVc.swift
//  swe599
//
//  Created by Onur on 13.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import UIKit


class CreateGroupVc: UIViewController, UITableViewDataSource {
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var tagsTable: UITableView!
    @IBOutlet var tagField: UITextField!
    
    private var tags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagsTable.dataSource = self
        tagsTable.allowsSelection = false
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    
    @IBAction func tagButtonTapped(_ sender: Any) {
        guard let tag = tagField.text, tag != "" else {
            return
        }
        if !tags.contains(tag){
            tags.append(tag)
            tagsTable.reloadData()
            tagField.text = ""
        }
    }
    
    @IBAction func createGroupTapped(_ sender: Any) {
        guard let groupName = nameField.text, groupName != "" else {
            self.presentAlert(message: "Please enter group name")
            return
        }
        if groupName.contains(" ") {
            self.presentAlert(message: "Group name can't contain spaces")
            return
        }
        self.showActivityIndicator()
        Group.create(name: groupName, tags: tags) { (result) in
            self.hideActivityIndicator()
            switch result{
            case .success(let group):
                AuthManager.currentUser?.add(group: group)
                self.navigationController?.popViewController(animated: true)
                break
            case .failure(let error):
                self.presentAlert(message: error.message)
            }
        }
    }
    
    // Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = tags[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tags.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

