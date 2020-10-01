//
//  CreateAcronym.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-09-29.
//

import Fluent

struct AcronymSchema {
    static let name = "acronyms"
    
    struct Fields {
        static let short = FieldKey.string("short")
        static let long = FieldKey.string("long")
        static let userID = FieldKey.string("userID")
    }
}

struct CreateAcronym: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AcronymSchema.name)
            .id()
            .field(AcronymSchema.Fields.short, .string, .required)
            .field(AcronymSchema.Fields.long, .string, .required)
            .field(AcronymSchema.Fields.userID, .uuid, .required, .references(UserSchema.name, UserSchema.Fields.id))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AcronymSchema.name).delete()
    }
}
