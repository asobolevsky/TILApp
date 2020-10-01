//
//  Category.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

import Fluent
import Vapor

final class Category: Model {
    static let schema = CategorySchema.name
    
    @ID
    var id: UUID?
    
    @Field(key: CategorySchema.Fields.name)
    var name: String
    
    @Siblings(
        through: AcronymCategoryPivot.self,
        from: \.$category,
        to: \.$acronym)
    var acronyms: [Acronym]
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension Category: Content {}
