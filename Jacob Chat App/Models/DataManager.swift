//
//  DataManager.swift
//  Jacob Chat App
//
//  Created by FDC Jacob on 6/16/20.
//  Copyright © 2020 FDC Jacob. All rights reserved.
//

//import Foundation
//import
//

import Firebase
import FirebaseMessaging
import PromiseKit

class DataManager {
    static let shared = DataManager()
    
    var ref: DatabaseReference!
    
    private init() {
        ref = Database.database().reference()
    }
    
    func getUsernameAsId() -> String {
        let userInfo = getCurrentUserInfo()
        return userInfo["username"] as? String ?? ""
    }
    
    func getCurrentUserInfo() -> [String: Any] {
        return UserDefaults.standard.dictionary(forKey: "user_information") ?? [:]
    }
    
    func clearUserInfo() {
        UserDefaults.standard.removeObject(forKey: "user_information")
    }
    
    func registerUser(username: String, password: String) -> Promise<Any> {
        return Promise<Any> { seal in
            ref.child("users").child(username).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let _username = value?["username"] as? String ?? ""
                
                // - username does not exist
                if username != _username {
                    
                    // - userInfo
                    let userInfo: [String: Any] = [
                        "username": username,
                        "password": password
                    ]
                    
                    // - save userinfo locally
                    self.saveUserInfoLocally(info: userInfo)
                    
                    // - save
                    self.ref.child("users").child(username).setValue(userInfo)
                    seal.fulfill(true)
                } else {
                    // - show error message
                    seal.reject(ChatAppError.userExists)
                }
            }, withCancel: { (error) in
                seal.reject(error)
            })
        }
    }
    
    func loginUser(username: String, password: String) -> Promise<Any> {
        return Promise<Any> { seal in
            ref.child("users").child(username).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let _username = value?["username"] as? String ?? ""
                
                // - username does exist
                if username == _username {
                    
                    // - userInfo
                    let userInfo: [String: Any] = [
                        "username": username,
                        "password": password
                    ]
                    
                    // - save userinfo locally
                    self.saveUserInfoLocally(info: userInfo)
                    
                    // - save
                    self.ref.child("users").child(username).setValue(userInfo)
                    seal.fulfill(true)
                
                // - user does not exist
                } else {
                    // - show error message
                    seal.reject(ChatAppError.invalidUser)
                }
            }, withCancel: { (error) in
                seal.reject(error)
            })
        }
    }
    
    private func saveUserInfoLocally(info: [String: Any]) {
        UserDefaults.standard.setValue(info, forKey: "user_information")
    }
    
    @discardableResult func updateFirebaseToken() -> Promise<Any> {
        return Promise<Any> { seal in
            let username = self.getUsernameAsId()
            if username.isEmpty {
                seal.reject(ChatAppError.invalidUser)
            } else {
                InstanceID.instanceID().instanceID(handler: { (result, error) in
                    if let error = error {
                        InstanceID.instanceID().deleteID(handler: { error in
                            if let _ = error {
                                // - something went wrong when deleting
                            } else {
                                // - successfully deleted
                            }
                        })
                        seal.fulfill(true)
                    } else if let result = result {
                        self.ref.child("users").child("\(username)/firebase_push_notif_token").setValue(result.token)
                        seal.fulfill(true)
                    } else {
                        seal.reject(ChatAppError.unknownError)
                    }
                })
            }
        }
    }
    
    func sendChat(message: String) -> Promise<Any> {
        let username = self.getUsernameAsId()
        return Promise<Any> { seal in
            if message.isEmpty {
                seal.reject(ChatAppError.messageInvalid)
            } else {
                let msg = [
                    "sender": username,
                    "message": message
                ]
                if let key = ref.child("messages").childByAutoId().key {
                    ref.child("messages").child(key).setValue(msg) { error, _ in
                        if let _ = error {
                            // - something went wrong while saving.
                            seal.reject(ChatAppError.messageInvalid)
                        } else {
                            seal.fulfill(true)
                        }
                    }
                } else {
                    seal.reject(ChatAppError.messageInvalid)
                }
            }
        }
    }
}

enum ChatAppError: Error, CustomStringConvertible {
    
    case unknownError
    case userExists
    case invalidUser
    case messageInvalid
    
    var description: String {
        var msg = "Unknown error."
        switch self {
        case .userExists:
            msg = "User already exist"
            break
        case .invalidUser:
            msg = "User does not exist"
            break
        case .messageInvalid:
            msg = "Message processing failed."
            break
        default:
            break
        }
        return msg
    }
    
    var errorCode: Int {
        var code = 1000
        switch self {
        case .userExists:
            code = 100
            break
        case .invalidUser:
            code = 101
            break
        case .messageInvalid:
            code = 102
            break
        default:
            break
        }
        return code
    }
    
    static func getError(code: Int) -> ChatAppError {
        var error: ChatAppError = .unknownError
        switch code {
        case 100:
            error = .userExists
            break
        case 101:
            error = .invalidUser
            break
        case 102:
            error = .messageInvalid
            break
        default:
            break
        }
        return error
    }
}
