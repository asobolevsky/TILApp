//
//  CreateCategory.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

import Fluent

struct CategorySchema {
    static let name = "categories"
    
    struct Fields {
        static let id = FieldKey.string("id")
        static let name = FieldKey.string("name")
    }
}

struct CreateCategory: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(CategorySchema.name)
            .id()
            .field(CategorySchema.Fields.name, .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(CategorySchema.name).delete()
    }
}
