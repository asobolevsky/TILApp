//
//  AcronymTest.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

@testable import App
import XCTVapor

final class AcronymTest: XCTestCase {
    private var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testAddAcronymToCategoryAPISucced() throws {
        let category = try App.Category.create(on: app.db)
        let acronym = try Acronym.create(on: app.db)
        
        try app.test(.POST, "/api/acronyms/\(acronym.id!)/categories/\(category.id!)", afterResponse: { response in
            XCTAssertEqual(response.status, .created)
        })
    }
    
    func testGetAcronymCategoriesAPI() throws {
        let category = try App.Category.create(on: app.db)
        let acronym = try Acronym.create(on: app.db)
        try acronym.$categories.attach([category], on: app.db).wait()
        
        try app.test(.GET, "/api/acronyms/\(acronym.id!)/categories/", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let receivedCategories = try response.content.decode([App.Category].self)
            XCTAssertEqual(receivedCategories.count, 1)
            
            let acronymCategory = receivedCategories.first!
            XCTAssertEqual(acronymCategory.id, category.id)
            XCTAssertEqual(acronymCategory.name, category.name)
        })
    }
}
