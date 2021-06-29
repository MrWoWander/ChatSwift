//
//  ContentView.swift
//  Shared
//
//  Created by Mikhail Ivanov on 29.06.2021.
//

import SwiftUI

struct ChatMainWindow: View {
    
    @State var message: String = ""
    
    @State var stackMessage: [ChatStackMessage] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Chat")
                .font(.title)
                .fontWeight(.bold)
            
            ScrollViewReader { value in
                GeometryReader { geometry in
                    ScrollView {
                        ForEach(stackMessage, id: \.id) { stack in
                            stack
                                .frame(width: geometry.size.width, height: 200)
                                .id(stack.id)
                        }
                        
                    }
                    .onAppear {
                        value.scrollTo(stackMessage.last?.id)
                    }
                    .onChange(of: stackMessage.count) { _ in
                        value.scrollTo(stackMessage.last?.id)
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
                    
                    let stack = ChatStackMessage(message: message)
                    
                    self.stackMessage.append(stack)
                    
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
    
    @State var id: UUID = UUID()
    
    let message: String
    
    var body: some View {
        VStack {
            Text(message)
        }
    }
}
