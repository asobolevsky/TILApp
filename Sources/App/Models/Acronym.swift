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
    
    init() {}
    
    init(id: UUID? = nil, short: String, long: String) {
        self.id = id
        self.short = short
        self.long = long
    }
}
