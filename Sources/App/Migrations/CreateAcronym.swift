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
    }
}

struct CreateAcronym: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AcronymSchema.name)
            .id()
            .field(AcronymSchema.Fields.short, .string, .required)
            .field(AcronymSchema.Fields.long, .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AcronymSchema.name).delete()
    }
}
