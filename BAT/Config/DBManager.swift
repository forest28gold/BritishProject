//
//  DBManager.swift
//  BAT
//
//  Created by AppsCreationTech on 2/21/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import Foundation

func documentsPath() -> String {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
}

struct ReadEvent {
    let id : Int?
    var userEmail : String
    var objectId : String
}

extension ReadEvent : Sqlable {
    static let id = Column("id", .integer, PrimaryKey(autoincrement: true))
    static let userEmail = Column("userEmail", .text)
    static let objectId = Column("objectId", .text)
    static let tableLayout = [id, userEmail, objectId]
    
    func valueForColumn(_ column : Column) -> SqlValue? {
        switch column {
        case ReadEvent.id: return id
        case ReadEvent.userEmail: return userEmail
        case ReadEvent.objectId: return objectId
        case _: return nil
        }
    }
    
    init(row : ReadRow) throws {
        id = try row.get(ReadEvent.id)
        userEmail = try row.get(ReadEvent.userEmail)
        objectId = try row.get(ReadEvent.objectId)
    }
}

struct DBManager {
    
    static public let path = documentsPath() + "/g==================================="
    static public var db : SqliteDatabase!
    
    static public func setUp() {
//        _ = try? SqliteDatabase.deleteDatabase(at: path)
        db = try! SqliteDatabase(filepath: path)
    }
    
    static public func createReadEventTable() {
        try! db.createTable(ReadEvent.self)
    }
    
    static public func readEvent(email: String, eventId: String) -> Bool {
        let events = try! ReadEvent.read().filter(ReadEvent.userEmail == email && ReadEvent.objectId == eventId).run(db)
        if events.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    static public func insertEvent(email: String, eventId: String) {
        let events = try! ReadEvent.read().filter(ReadEvent.userEmail == email && ReadEvent.objectId == eventId).run(db)
        if events.count > 0 {
            return
        } else {
            let event = ReadEvent.init(id: nil, userEmail: email, objectId: eventId)
            try! event.insert().run(db)
            return
        }
    }
    
    static public func deleteEvent(email: String, eventId: String) {
        try! ReadEvent.delete(ReadEvent.userEmail == email && ReadEvent.objectId == eventId).run(db)
    }
    
    static public func deleteAllEvent(email: String) {
        try! ReadEvent.delete(ReadEvent.userEmail == email).run(db)
    }
    
}
