//
//  Socket.swift
//  swe599
//
//  Created by Onur on 16.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import SocketIO

class Socket {
    static var shared: Socket!
    let manager: SocketManager
    let socketio: SocketIOClient
    var messageCallback: ((Message)->())?
    
    static func init_socket(){
        shared = Socket()
    }
    
    private init(){
        manager = SocketManager(socketURL: URL(string: Config.BaseUrl)!, config: [.extraHeaders(AuthManager.getAuthHeaders() ?? [:])])
        socketio = manager.defaultSocket
        self.initEvents()
        socketio.connect()
    }
    
    private func initEvents(){
        onConnect()
        onNewMessage()
    }
    
    private func onConnect(){
        socketio.on(clientEvent: .connect) { (data, ack) in
            Logger.Log(key: "socket", message: "connected")
        }
        socketio.on(clientEvent: .disconnect) { (data, ack) in
            Logger.Log(key: "socket", message: "disconnected")
        }
    }
    
    private func onNewMessage(){
        socketio.on("new_message") {[weak self] (data, ack) in
            Logger.Log(key: "socket", message: "new message")
            guard let json  = data[0] as? [String: Any], let message = Message(json: json) else {
                return
            }
            self?.messageCallback?(message)
        }
    }
    
    func joinPost(postId: Int, callback: @escaping (Message)->()){
        messageCallback = callback
        socketio.emitWithAck("join_post", postId).timingOut(after: 0) { (ackData) in
            Logger.Log(key: "socket", message: "join post ack with \(ackData)")
        }
    }
    
    func leavePost(postId: Int){
        socketio.emitWithAck("leave_post", postId).timingOut(after: 0) { (ackData) in
            Logger.Log(key: "socket", message: "leave post ack with \(ackData)")
        }
    }
    
    func sendMessage(text: String, postId: Int){
        socketio.emitWithAck("send_message", ["text": text, "post-id": postId]).timingOut(after: 0) { (ackData) in
            Logger.Log(key: "socket", message: "send message ack with \(ackData)")
        }
    }
    
    
    
//    var socket: SocketIOClient!
//    var manager: SocketManager!
//    func socketinit(){
//        manager = SocketManager(socketURL: URL(string: "http://127.0.0.1:5000")!)
//        socket = manager.defaultSocket
//        socket.on(clientEvent: .connect) { (data, ack) in
//            print("socket connected")
//        }
//        socket.on("deneme") { (data, ack) in
//            print("socket \(data)")
//            ack.with("gotit")
//        }
//        socket.connect()
//    }
}
