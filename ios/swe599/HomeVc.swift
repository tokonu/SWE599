//
//  HomeVc.swift
//  swe599
//
//  Created by Onur on 13.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import UIKit

class HomeVc: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var createGroupButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        tableView.reloadData()
    }
    
    
    @IBAction func createGroupButtonTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreateGroupVc")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        AuthManager.logout()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query != "", query != " " else {
            searchBar.endEditing(true)
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchVc") as! SearchVc
        vc.initialQuery = query
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AuthManager.currentUser?.groups.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = AuthManager.currentUser?.groups[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "GroupVc") as! GroupVc
        vc.group = AuthManager.currentUser!.groups[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
