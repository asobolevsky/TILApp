//
//  CraeteUser.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-09-30.
//

import Fluent

struct UserSchema {
    static let name = "users"
    
    struct Fields {
        static let id = FieldKey.string("id")
        static let name = FieldKey.string("name")
        static let username = FieldKey.string("username")
    }
}

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserSchema.name)
            .id()
            .field(UserSchema.Fields.name, .string, .required)
            .field(UserSchema.Fields.username, .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserSchema.name).delete()
    }
}
