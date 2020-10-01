//
//  AcronymCategoryPivot.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

import Fluent
import Vapor

final class AcronymCategoryPivot: Model {
    static let schema = AcronymCategoryPivotSchema.name
    
    @ID
    var id: UUID?
    
    @Parent(key: AcronymCategoryPivotSchema.Fields.acronymID)
    var acronym: Acronym
    
    @Parent(key: AcronymCategoryPivotSchema.Fields.categoryID)
    var category: Category
    
    init() {}
    
    init(id: UUID? = nil, acronym: Acronym, category: Category) throws {
        self.id = id
        self.$acronym.id = try acronym.requireID()
        self.$category.id = try category.requireID()
    }
    
}


