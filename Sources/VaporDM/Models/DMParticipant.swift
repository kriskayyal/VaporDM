//
//  DMParticipant.swift
//  VaporDM
//
//  Created by Shial on 20/04/2017.
//
//

import Foundation
import Vapor
import Fluent

public typealias DMUser = Model & DMParticipant

public enum DMUserStatus {
    case offline
    case online
    case away
}

public protocol DMParticipant {
    static func directMessageLog(_ log: DMLog)
    static func directMessageEvent(_ event: DMEvent)
}

public extension DMParticipant where Self: Model {    
    public func rooms() throws -> Siblings<DMRoom> {
        return try siblings()
    }
    
    public func messages() throws -> Children<DMDirective> {
        return children(DMDirective.Constants.owner)
    }
}
