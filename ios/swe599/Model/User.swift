//
//  User.swift
//  swe599
//
//  Created by Onur on 12.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import Foundation

class User {
    let id: Int
    let email: String
    var groups: [Group] = []
    
    init(id: Int, email: String) {
        self.id = id
        self.email = email
    }
    
    convenience init?(json: [String: Any]){
        guard let id = json["id"] as? Int, let email = json["email"] as? String else {
            return nil
        }
        self.init(id: id, email: email)
        guard let groupsArr = json["groups"] as? [[String: Any]] else { return }
        for groupDict in groupsArr {
            if let group = Group(json: groupDict) {
                self.add(group: group)
            }
        }
    }
    
    func contains(group: Group) -> Bool {
        return groups.contains(where: { $0.id == group.id})
    }
    
    func add(group: Group){
        if !groups.contains(where: { $0.id == group.id}) {
            groups.append(group)
        }
    }
    func remove(group: Group){
        groups = groups.filter({ $0.id != group.id })
    }
    
}
