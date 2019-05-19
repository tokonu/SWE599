//
//  LoginManager.swift
//  swe599
//
//  Created by Onur on 11.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import Foundation
import Alamofire


class AuthManager {
    private static let TokenKey = "token"
    static var currentUser: User?
    
    static func isLoggedIn() -> Bool {
        return getToken() != nil
        //return false
    }
    
    static func logout() {
        UserDefaults.standard.removeObject(forKey: TokenKey)
    }
    
    private static func setToken(token: String){
        UserDefaults.standard.set(token, forKey: TokenKey)
    }
    
    private static func getToken() -> String? {
        return UserDefaults.standard.object(forKey: TokenKey) as? String
    }
    
    static func getAuthHeaders() -> HTTPHeaders? {
        guard let token = getToken() else {
            return nil
        }
        return ["Authorization": "Bearer \(token)"]
    }
    
    static func signup(email: String, password: String, callback: @escaping (_ errorMessage: String?)->()){
        let params = ["email": email, "password": password]
        Alamofire.request(Config.signupUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                let defaultErrorMessage = "Something went grong"
                guard let statusCode = response.response?.statusCode else {
                    callback(defaultErrorMessage)
                    return
                }
                switch statusCode {
                case 201:
                    Logger.Log(key: "auth", message: "signup response: \(response.result.value ?? "nil")")
                    guard let json = response.result.value as? [String: Any], let token = json["token"] as? String else {
                        callback(defaultErrorMessage)
                        return
                    }
                    setToken(token: token)
                    callback(nil)
                case 400:
                    if let json = response.result.value as? [String: String], let message = json["message"]{
                        callback(message)
                    }else{
                        callback(defaultErrorMessage)
                    }
                default:
                    callback(defaultErrorMessage)
                }
        }
    }
    
    static func login(email: String, password: String, callback: @escaping (_ errorMessage: String?)->()){
        let params = ["email": email, "password": password]
        Alamofire.request(Config.loginUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                let defaultErrorMessage = "Something went grong"
                guard let statusCode = response.response?.statusCode else {
                    callback(defaultErrorMessage)
                    return
                }
                switch statusCode {
                case 200:
                    Logger.Log(key: "auth", message: "login response: \(response.result.value ?? "nil")")
                    guard let json = response.result.value as? [String: Any], let token = json["token"] as? String else {
                        callback(defaultErrorMessage)
                        return
                    }
                    setToken(token: token)
                    callback(nil)
                case 400:
                    if let json = response.result.value as? [String: String], let message = json["message"]{
                        callback(message)
                    }else{
                        callback(defaultErrorMessage)
                    }
                default:
                    callback(defaultErrorMessage)
                }
        }
    }
    
    
    static func getMe(callback: @escaping (Swift.Result<User, AuthError>)->()){
        Alamofire.request(Config.meUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: getAuthHeaders())
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                let defaultError = AuthError(message: "Something went grong")
                guard let statusCode = response.response?.statusCode else {
                    callback(.failure(defaultError))
                    return
                }
                switch statusCode {
                case 200:
                    Logger.Log(key: "auth", message: "me response: \(response.result.value ?? "nil")")
                    guard let json = response.result.value as? [String: Any], let user = User(json: json) else {
                        callback(.failure(defaultError))
                        return
                    }
                    AuthManager.currentUser = user
                    callback(.success(user))
                case 401:
                    AuthManager.logout()
                    callback(.failure(AuthError(message: "Unauthorised")))
                default:
                    callback(.failure(defaultError))
                }
        }
    }
}
