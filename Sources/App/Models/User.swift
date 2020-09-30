//
//  User.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-09-30.
//

import Fluent
import Vapor

final class User: Model {
    static let schema = UserSchema.name
    
    @ID
    var id: UUID?
    
    @Field(key: UserSchema.Fields.name)
    var name: String
    
    @Field(key: UserSchema.Fields.username)
    var username: String
    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String) {
        self.id = id
        self.name = name
        self.username = username
    }
}

extension User: Content {}
