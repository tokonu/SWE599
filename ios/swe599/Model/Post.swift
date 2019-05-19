//
//  Post.swift
//  swe599
//
//  Created by Onur on 13.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import Foundation


class Post {
    let id: Int
    let groupId: Int
    let title: String
    let description: String?
    let createdAt: Double
    var messages = [Message]()
    
    init(id: Int, groupId: Int, title: String, description: String?, createdAt: Double) {
        self.id = id
        self.groupId = groupId
        self.title = title
        self.description = description
        self.createdAt = createdAt
    }
    
    convenience init?(json: [String: Any]){
        guard let id = json["id"] as? Int, let groupId = json["group-id"] as? Int, let title = json["title"] as? String,
            let createdAt = json["created-at"] as? Double else {
            return nil
        }
        self.init(id: id, groupId: groupId, title: title, description: json["description"] as? String, createdAt: createdAt)
    }
    
    func set(messages: [Message]){
        self.messages = messages
    }
    
    func add(message: Message){
        if !self.messages.contains(where: { $0.id == message.id }){
            self.messages.append(message)
        }
    }
}
