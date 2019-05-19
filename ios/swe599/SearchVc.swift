//
//  SearchVc.swift
//  swe599
//
//  Created by Onur on 13.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import UIKit

class SearchVc: UIViewController, UISearchBarDelegate, UITableViewDataSource, SearchCellDelegate {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var initialQuery: String?
    private var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.navigationItem.title = "Search"
        self.navigationController?.isNavigationBarHidden = false
        self.searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.text = initialQuery
        if initialQuery != nil {
            searchGroups(with: initialQuery!)
        }
    }
    
    func searchGroups(with query: String){
        self.showActivityIndicator()
        Group.search(query: query) { (result) in
            self.hideActivityIndicator()
            switch result {
            case .success(let groups):
                self.groups = groups
                self.tableView.reloadData()
            case .failure(let error):
                self.presentAlert(message: error.message)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query != "", query != " " else {
            searchBar.endEditing(true)
            return
        }
        searchGroups(with: query)
    }
    
    func joinRequestStarted() {
        self.showActivityIndicator()
    }
    
    func joinRequestEnded(result: Result<Group, ApiError>) {
        self.hideActivityIndicator()
        switch result {
        case .success(let group):
            AuthManager.currentUser?.add(group: group)
            self.tableView.reloadData()
        case .failure(let error):
            self.presentAlert(message: error.message)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SearchCell
        cell.update(for: groups[indexPath.row])
        cell.delegate = self
        return cell
    }
}

protocol SearchCellDelegate: class {
    func joinRequestStarted()
    func joinRequestEnded(result: Result<Group, ApiError>)
}

class SearchCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var joinButton: UIButton!
    private var group: Group?
    weak var delegate: SearchCellDelegate?
    
    func update(for group: Group){
        self.group = group
        self.name.text = group.name
        
        if AuthManager.currentUser?.contains(group: group) == true {
            joinButton.alpha = 0
            joinButton.isEnabled = false
        }else{
            joinButton.alpha = 1
            joinButton.isEnabled = true
        }
    }
    
    @IBAction func joinTapped(_ sender: Any) {
        guard let group = self.group else { return }
        self.delegate?.joinRequestStarted()
        Group.join(group: group) { (result) in
            Delay.onMain(secs: 0, callback: {
                self.delegate?.joinRequestEnded(result: result)
            })
        }
    }
}
