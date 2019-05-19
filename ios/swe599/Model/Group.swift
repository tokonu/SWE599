//
//  Group.swift
//  swe599
//
//  Created by Onur on 13.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import Foundation


class Group {
    let id: Int
    let name: String
    let tags: [String]
    var posts: [Post] = []
    
    init(id: Int, name: String, tags: [String]?) {
        self.id = id
        self.name = name
        self.tags = tags ?? []
    }
    
    convenience init?(json: [String: Any]){
        guard let id = json["id"] as? Int, let name = json["name"] as? String else {
            return nil
        }
        self.init(id: id, name: name, tags: json["tags"] as? [String])
    }
    
    func setPosts(posts: [Post]){
        self.posts = posts
    }
    
    func add(post: Post){
        if !posts.contains(where: { $0.id != post.id }) {
            posts.append(post)
        }
    }
}
