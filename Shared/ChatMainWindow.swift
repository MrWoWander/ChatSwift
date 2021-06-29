//
//  ContentView.swift
//  Shared
//
//  Created by Mikhail Ivanov on 29.06.2021.
//

import SwiftUI

struct ChatMainWindow: View {
    
    @State var message: String = ""
    
    @StateObject var websocket = WebSocketObservable()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                VStack {
                    Text("Chat")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Users: \(websocket.countUsers)")
                }
                Spacer()
                
                Text("User ID: \(websocket.userID)")
            }
            
            Divider()
            
            ScrollViewReader { value in
                GeometryReader { geometry in
                    ScrollView {
                        ForEach(websocket.stackMessage, id: \.message.id) { stack in
                            stack
                                .frame(width: geometry.size.width)
                                .padding(.bottom, 10.0)
                                .id(stack.message.id)
                        }
                    }
                    .onAppear {
                        value.scrollTo(websocket.stackMessage.last?.message.id)
                    }
                    .onChange(of: websocket.stackMessage.count) { _ in
                        value.scrollTo(websocket.stackMessage.last?.message.id)
                    }
                }
            }
            
            Divider()
            
            HStack {
                TextField("message", text: $message,
                          onCommit: {
                            messageAction()
                          })
                
                Button(action: {
                    messageAction()
                }, label: {
                    Text("Send")
                })
            }
        }
        .padding(.all, 10.0)
    }
    
    func messageAction() {
        if message.isEmpty {
            return
        }
        
        websocket.sendMessage(message: message)
        
        message = ""
    }
}

struct ChatStackMessage: View {
    
    @State var message: MessageModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Id users: \(message.userId)")
                    .font(.subheadline)
                Spacer()
                Text(localizedDate(message.date))
                    .font(.subheadline)
            }
            Text(message.message)
                .font(.body)
        }
    }
    
    func localizedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.MM.yy HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from: date)
    }
}
