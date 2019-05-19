//
//  PostNetwork.swift
//  swe599
//
//  Created by Onur on 14.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import Foundation
import Alamofire

extension Post {
    
    static func list(for group: Group, callback: @escaping (Swift.Result<[Post], ApiError>)->()){
        Alamofire.request(Config.postListUrl(groupId: group.id), method: .get, parameters: nil, encoding: URLEncoding.default, headers: AuthManager.getAuthHeaders())
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                let defaultError = ApiError(message: "Something went grong")
                guard let statusCode = response.response?.statusCode else {
                    callback(.failure(defaultError))
                    return
                }
                switch statusCode {
                case 200:
                    Logger.Log(key: "post", message: "get post: \(response.result.value ?? "nil")")
                    guard let resp = response.result.value as? [String: Any], let jsonArr = resp["posts"] as? [[String: Any]] else {
                        callback(.failure(defaultError))
                        return
                    }
                    var posts = [Post]()
                    for json in jsonArr {
                        if let p = Post(json: json) {
                            posts.append(p)
                        }
                    }
                    callback(.success(posts))
                case 401:
                    callback(.failure(ApiError(message: "Unauthorised")))
                default:
                    callback(.failure(defaultError))
                }
        }
    }
    
    static func create(title: String, description: String, groupId: Int, callback: @escaping (Swift.Result<Post, ApiError>)->()){
        let params: [String: Any] = ["title": title, "description": description]
        Alamofire.request(Config.postCreateUrl(groupId: groupId), method: .post, parameters: params, encoding: JSONEncoding.default, headers: AuthManager.getAuthHeaders())
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                let defaultError = ApiError(message: "Something went grong")
                guard let statusCode = response.response?.statusCode else {
                    callback(.failure(defaultError))
                    return
                }
                switch statusCode {
                case 201:
                    Logger.Log(key: "post", message: "create response: \(response.result.value ?? "nil")")
                    guard let json = response.result.value as? [String: Any], let post = Post(json: json) else {
                        callback(.failure(defaultError))
                        return
                    }
                    callback(.success(post))
                case 400:
                    if let json = response.result.value as? [String: String], let message = json["message"]{
                        callback(.failure(ApiError(message: message)))
                    }else{
                        callback(.failure(defaultError))
                    }
                case 401:
                    callback(.failure(ApiError(message: "Unauthorised")))
                default:
                    callback(.failure(defaultError))
                }
        }
    }
    
    static func getMessages(for post: Post, callback: @escaping (Swift.Result<[Message], ApiError>)->()){
        Alamofire.request(Config.postMessagesUrl(groupId: post.groupId, postId: post.id), method: .get, parameters: nil, encoding: URLEncoding.default, headers: AuthManager.getAuthHeaders())
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                let defaultError = ApiError(message: "Something went grong")
                guard let statusCode = response.response?.statusCode else {
                    callback(.failure(defaultError))
                    return
                }
                switch statusCode {
                case 200:
                    Logger.Log(key: "post", message: "get post: \(response.result.value ?? "nil")")
                    guard let resp = response.result.value as? [String: Any], let jsonArr = resp["messages"] as? [[String: Any]] else {
                        callback(.failure(defaultError))
                        return
                    }
                    var messages = [Message]()
                    for json in jsonArr {
                        if let m = Message(json: json) {
                            messages.append(m)
                        }
                    }
                    callback(.success(messages))
                case 401:
                    callback(.failure(ApiError(message: "Unauthorised")))
                default:
                    callback(.failure(defaultError))
                }
        }
    }
}
