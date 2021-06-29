//
//  WebSocketObservable.swift
//  ChatSwift
//
//  Created by Mikhail Ivanov on 29.06.2021.
//

import SwiftUI

class WebSocketObservable: ObservableObject {
    
    @Published var socket: URLSessionWebSocketTask
    
    @Published var stackMessage: [ChatStackMessage] = []
    
    let idUsers = UUID()
    
    init() {
        let session = URLSession(configuration: .default)
        let url = URL(string: "ws://127.0.0.1:8080/chat/\(idUsers.uuidString)")!
        self.socket = session.webSocketTask(with: url)
        socket.resume()
        
        self.readMessage()
    }
    
    func sendMessage(message: String) {
        let messageModel = MessageModel(id: UUID(), userId: idUsers, message: message, date: Date())
        
        let stack = ChatStackMessage(message: messageModel)
        
        do {
            let jsonData = try JSONEncoder().encode(messageModel)
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            if let str = jsonString {
                print(str)
                socket.send(.string(str)) { _ in }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        stackMessage.append(stack)
    }
    
    func readMessage() {
        DispatchQueue.global().async {
            self.socket.receive{ result in
                switch result {
                case .success(let data):
                    switch data {
                    case.string(let message):
                        let jsonData = Data(message.utf8)
                        print(message)
                        do {
                            let mes = try JSONDecoder().decode(MessageModel.self, from: jsonData)
                            
                            DispatchQueue.main.async {
                                self.stackMessage.append(.init(message: mes))
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    case .data(_):
                        break
                    @unknown default:
                        debugPrint("Unknown message")
                    }
                    
                case .failure(_):
                    break
                }
                
                self.readMessage()
            }
        }
    }
}
