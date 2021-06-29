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
    
    func readMessage() {
        socket.receive{ result in
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
