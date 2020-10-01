//
//  CreateAcronymCategoryPivot.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

import Fluent

struct AcronymCategoryPivotSchema {
    static let name = "acronym-category-pivot"
    
    struct Fields {
        static let id = FieldKey.string("id")
        static let acronymID = FieldKey.string("acronymID")
        static let categoryID = FieldKey.string("categoryID")
    }
}

struct CreateAcronymCategoryPivot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AcronymCategoryPivotSchema.name)
            .id()
            .field(AcronymCategoryPivotSchema.Fields.acronymID, .uuid, .required, .references(AcronymSchema.name, AcronymSchema.Fields.id, onDelete: .cascade))
            .field(AcronymCategoryPivotSchema.Fields.categoryID, .uuid, .required, .references(CategorySchema.name, CategorySchema.Fields.id, onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AcronymCategoryPivotSchema.name).delete()
    }
}
