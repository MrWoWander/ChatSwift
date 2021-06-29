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
            
            Text("Chat")
                .font(.title)
                .fontWeight(.bold)
            
            ScrollViewReader { value in
                GeometryReader { geometry in
                    ScrollView {
                        ForEach(websocket.stackMessage, id: \.message.id) { stack in
                            stack
                                .frame(width: geometry.size.width, height: 100)
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
            
            Spacer()
            
            HStack {
                TextField("message", text: $message)
                
                Button(action: {
                    
                    if message.isEmpty {
                        return
                    }
                    
                    let messageModel = MessageModel(id: UUID(), userId: websocket.idUsers, message: message, date: Date())
                    
                    let stack = ChatStackMessage(message: messageModel)
                    
                    do {
                        let jsonData = try JSONEncoder().encode(messageModel)
                        let jsonString = String(data: jsonData, encoding: .utf8)
                        
                        if let str = jsonString {
                            print(str)
                            websocket.socket.send(.string(str)) { _ in }
                        }
                    } catch {
                        
                    }
                    websocket.stackMessage.append(stack)
                    
                    message = ""
                    
                }, label: {
                    Text("Send")
                })
            }
        }
        .padding(.all, 10.0)
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
