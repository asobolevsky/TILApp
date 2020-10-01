//
//  Acronym+Testable.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

@testable import App
import Fluent

extension Acronym {
    static func create(
        short: String = "TIL",
        long: String = "Today I learned",
        user: User? = nil,
        on database: Database
    ) throws -> Acronym {
        var acronymUser = user
        if acronymUser == nil {
            acronymUser = try User.create(on: database)
        }
        
        let acronym = Acronym(short: short, long: long, userID: acronymUser!.id!)
        try acronym.save(on: database).wait()
        return acronym
    }
}
