//
//  Category+Testable.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

@testable import App
import Fluent

extension App.Category {
    static func create(
        name: String = "Random",
        on database: Database
    ) throws -> App.Category {
        let category = Category(name: name)
        try category.save(on: database).wait()
        return category
    }
}
