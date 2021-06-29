//
//  MessageModel.swift
//  ChatSwift
//
//  Created by Mikhail Ivanov on 29.06.2021.
//

import Foundation

struct MessageModel: Codable {
    let id: UUID
    let userId: UUID
    
    let message: String
    let date: Date
    
    
    internal init(id: UUID, userId: UUID, message: String, date: Date) {
        self.id = id
        self.userId = userId
        self.message = message
        self.date = date
    }
    
    enum CodingKeys : String, CodingKey {
            case id, userId, message, date
        }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        
        try container.encode(message, forKey: .message)
        
        let dateFormat = DateFormatter()
        
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        
        if let timeZoneGMT = TimeZone.init(abbreviation: "GMT") {
            dateFormat.timeZone = timeZoneGMT
        }
        
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let dateString = dateFormat.string(from: date)
        try container.encode(dateString, forKey: .date)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        
        message = try container.decode(String.self, forKey: .message)
        
        let dateString = try container.decode(String.self, forKey: .date)
        let dateFormat = DateFormatter()
        
        if let timeZoneGMT = TimeZone.init(abbreviation: "GMT") {
            dateFormat.timeZone = timeZoneGMT
        }
        
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormat.date(from: dateString) {
            self.date = date
        } else {
            date = Date()
        }
    }
}
