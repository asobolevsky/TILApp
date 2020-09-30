//
//  Acronym.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-09-29.
//

import Fluent
import Vapor

final class Acronym: Model {
    static let schema = AcronymSchema.name
    
    @ID
    var id: UUID?
    
    @Field(key: AcronymSchema.Fields.short)
    var short: String
    
    @Field(key: AcronymSchema.Fields.long)
    var long: String
    
    @Parent(key: AcronymSchema.Fields.userID)
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, short: String, long: String, userID: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID
    }
}

extension Acronym: Content {}
