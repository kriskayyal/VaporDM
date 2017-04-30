//
//  DMDirective.swift
//  VaporDM
//
//  Created by Shial on 19/04/2017.
//
//

import Foundation
import Vapor
import Fluent

public final class DMDirective {
    public static var entity = "dmdirective"
    public var exists = false
    
    public var id: Node?
    public var room: Node?
    public var owner: Node?
    
    struct Constants {
        static let id = "id"
        static let room = "roomid"
        static let owner = "ownerid"
        static let created = "created"
        static let updated = "updated"
        static let message = "message"
        static let isSeen = "seen"
        static let isSystemMessage = "system"
    }
    
    public var message: String
    public var isSystemMessage: Bool
    public var isSeen: Bool = false
    public var created: Date = Date()
    public var updated: Date = Date()
    
    public init(message: String, system: Bool = false) throws {
        self.message = message
        self.isSystemMessage = system
    }
    
    public init(node: Node, in context: Context) throws {
        id = try node.extract(Constants.id)
        room = try node.extract(Constants.room)
        owner = try node.extract(Constants.owner)
        created = try node.extract(Constants.created,
                                        transform: Date.init(timeIntervalSince1970:))
        updated = try node.extract(Constants.updated,
                                        transform: Date.init(timeIntervalSince1970:))
        message = try node.extract(Constants.message)
        isSeen = try node.extract(Constants.isSeen)
        isSystemMessage = try node.extract(Constants.isSystemMessage)
    }
}

extension DMDirective: Model {
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [Constants.id: id,
                               Constants.room: room,
                               Constants.owner: owner,
                               Constants.message: message,
                               Constants.isSeen: isSeen,
                               Constants.isSystemMessage: isSystemMessage,
                               Constants.created: created.timeIntervalSince1970,
                               Constants.updated: updated.timeIntervalSince1970])
    }
}

extension DMDirective: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(DMDirective.entity, closure: { (directive) in
            directive.id()
            directive.parent(idKey: Constants.room, optional: false)
            directive.parent(idKey: Constants.owner, optional: false)
            directive.string(Constants.message)
            directive.bool(Constants.isSystemMessage)
            directive.bool(Constants.isSeen)
            directive.double(Constants.created)
            directive.double(Constants.updated)
        })
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(DMDirective.entity)
    }
}

extension DMDirective {
    public func getRoom() throws -> DMRoom? {
        return try parent(room).first()
    }
    public func getOwner<T:DMUser>() throws -> T? {
        return try parent(owner).first()
    }
}