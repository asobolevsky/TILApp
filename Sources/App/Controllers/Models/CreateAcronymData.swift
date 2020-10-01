//
//  CreateAcronymData.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

import Vapor

struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}
