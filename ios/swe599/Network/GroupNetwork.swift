//
//  Group.swift
//  swe599
//
//  Created by Onur on 13.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import Foundation
import Alamofire


extension Group {
    
    static func create(name: String, tags: [String], callback: @escaping (Swift.Result<Group, ApiError>)->()){
        let params: [String: Any] = ["name": name, "tags": tags]
        Alamofire.request(Config.groupCreateUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: AuthManager.getAuthHeaders())
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                let defaultError = ApiError(message: "Something went grong")
                guard let statusCode = response.response?.statusCode else {
                    callback(.failure(defaultError))
                    return
                }
                switch statusCode {
                case 201:
                    Logger.Log(key: "group", message: "create response: \(response.result.value ?? "nil")")
                    guard let json = response.result.value as? [String: Any], let group = Group(json: json) else {
                        callback(.failure(defaultError))
                        return
                    }
                    callback(.success(group))
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
    
    static func search(query: String, callback: @escaping (Swift.Result<[Group], ApiError>)->()){
        let params: [String: Any] = ["q": query]
        Alamofire.request(Config.groupSearchUrl, method: .get, parameters: params, encoding: URLEncoding.default, headers: AuthManager.getAuthHeaders())
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                let defaultError = ApiError(message: "Something went grong")
                guard let statusCode = response.response?.statusCode else {
                    callback(.failure(defaultError))
                    return
                }
                switch statusCode {
                case 200:
                    Logger.Log(key: "group", message: "search response: \(response.result.value ?? "nil")")
                    guard let resp = response.result.value as? [String: Any], let jsonArr = resp["groups"] as? [[String: Any]] else {
                        callback(.failure(defaultError))
                        return
                    }
                    var groups = [Group]()
                    for json in jsonArr {
                        if let g = Group(json: json){
                            groups.append(g)
                        }
                    }
                    callback(.success(groups))
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
    
    static func join(group: Group, callback: @escaping (Swift.Result<Group, ApiError>)->()){
        Alamofire.request(Config.groupJoinUrl(groupId: group.id), method: .post, parameters: nil, encoding: URLEncoding.default, headers: AuthManager.getAuthHeaders())
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                let defaultError = ApiError(message: "Something went grong")
                guard let statusCode = response.response?.statusCode else {
                    callback(.failure(defaultError))
                    return
                }
                switch statusCode {
                case 200:
                    callback(.success(group))
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
    
    static func leave(group: Group, callback: @escaping (Swift.Result<Group, ApiError>)->()){
        Alamofire.request(Config.groupLeaveUrl(groupId: group.id), method: .post, parameters: nil, encoding: URLEncoding.default, headers: AuthManager.getAuthHeaders())
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                let defaultError = ApiError(message: "Something went grong")
                guard let statusCode = response.response?.statusCode else {
                    callback(.failure(defaultError))
                    return
                }
                switch statusCode {
                case 200:
                    callback(.success(group))
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
}
