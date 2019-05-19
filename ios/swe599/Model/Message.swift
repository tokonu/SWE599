//
//  Message.swift
//  swe599
//
//  Created by Onur on 15.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import Foundation

class Message {
    let id: Int
    let text: String
    let createdAt: Double
    let creatorId: Int
    let postId: Int
    
    init(id: Int, text: String, createdAt: Double, creatorId: Int, postId: Int) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.creatorId = creatorId
        self.postId = postId
    }
    
    convenience init?(json: [String: Any]){
        guard let id = json["id"] as? Int, let text = json["text"] as? String, let createdAt = json["created-at"] as? Double,
            let creatorId = json["creator-id"] as? Int, let postId = json["post-id"] as? Int else {
                return nil
        }
        self.init(id: id, text: text, createdAt: createdAt, creatorId: creatorId, postId: postId)
    }
    
}
