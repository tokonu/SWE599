//
//  Config.swift
//  swe599
//
//  Created by Onur on 11.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//


class Config {
    static let BaseUrl = "http://34.239.56.10/"
    
    // Auth
    static let signupUrl = BaseUrl + "auth/signup"
    static let loginUrl = BaseUrl + "auth/login"
    static let meUrl = BaseUrl + "auth/me"
    
    //Group
    static let groupCreateUrl = BaseUrl + "groups/create"
    static let groupSearchUrl = BaseUrl + "groups/search"
    static func groupJoinUrl(groupId: Int) -> String {
        return BaseUrl + "groups/\(groupId)/join"
    }
    static func groupLeaveUrl(groupId: Int) -> String {
        return BaseUrl + "groups/\(groupId)/leave"
    }
    
    //Post
    static func postListUrl(groupId: Int) -> String {
        return BaseUrl + "groups/\(groupId)/posts"
    }
    static func postCreateUrl(groupId: Int) -> String {
        return BaseUrl + "groups/\(groupId)/posts/create"
    }
    static func postMessagesUrl(groupId: Int, postId:Int) -> String {
        return BaseUrl + "groups/\(groupId)/posts/\(postId)/messages"
    }
}

