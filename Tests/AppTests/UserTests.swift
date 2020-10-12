//
//  UserTests.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

@testable import App
//import XCTVapor
//
//final class UserTests: XCTestCase {
//    private var app: Application!
//    
//    override func setUpWithError() throws {
//        app = try Application.testable()
//    }
//    
//    override func tearDownWithError() throws {
//        app.shutdown()
//    }
//    
//    func testUserCreateAPIReturnsNewUser() throws {
//        let user = generateTestUser()
//        
//        try app.test(.POST, "/api/users", beforeRequest: { req in
//            try req.content.encode(user)
//        }, afterResponse: { response in
//            XCTAssertEqual(response.status, .ok)
//            
//            let receivedUser = try response.content.decode(User.self)
//            XCTAssertEqual(user.name, receivedUser.name)
//            XCTAssertEqual(user.username, receivedUser.username)
//        })
//    }
//    
//    func testUserAllAPIReturnsCreatedUser() throws {
//        let user = generateTestUser()
//        try app.test(.POST, "/api/users", beforeRequest: { req in
//            try req.content.encode(user)
//        }, afterResponse: { response in
//            let newUser = try response.content.decode(User.self)
//            user.id = newUser.id
//        })
//        
//        try app.test(.GET, "/api/users", afterResponse: { response in
//            XCTAssertEqual(response.status, .ok)
//            
//            let receivedUsers = try response.content.decode([User].self)
//            XCTAssertEqual(receivedUsers.count, 1)
//            
//            let newUser = receivedUsers.first!
//            XCTAssertEqual(newUser.id, user.id)
//            XCTAssertEqual(newUser.name, user.name)
//            XCTAssertEqual(newUser.username, user.username)
//        })
//    }
//    
//    func testUserCanBeRetrievedFromAPI() throws {
//        let user = try User.create(on: app.db)
//        
//        try app.test(.GET, "/api/users") { response in
//            XCTAssertEqual(response.status, .ok)
//            
//            let receivedUser = try response.content.decode([User].self).first
//            XCTAssertEqual("John Doe", receivedUser?.name)
//            XCTAssertEqual("JD", receivedUser?.username)
//            XCTAssertEqual(user.id, receivedUser?.id)
//        }
//        
//    }
//    
//    func testGetSingleUserAPI() throws {
//        let user = try User.create(on: app.db)
//        
//        try app.test(.GET, "/api/users/\(user.id!)", afterResponse: { response in
//            XCTAssertEqual(response.status, .ok)
//            
//            let receivedUser = try response.content.decode(User.self)
//            XCTAssertEqual(receivedUser.id, user.id)
//            XCTAssertEqual(receivedUser.name, user.name)
//            XCTAssertEqual(receivedUser.username, user.username)
//        })
//    }
//    
//    func testGetUserAcronymsAPI() throws {
//        let user = try User.create(on: app.db)
//        let acronym = try Acronym.create(user: user, on: app.db)
//        
//        try app.test(.GET, "/api/users/\(user.id!)/acronyms", afterResponse: { response in
//            XCTAssertEqual(response.status, .ok)
//            
//            let receivedAcronyms = try response.content.decode([Acronym].self)
//            XCTAssertEqual(receivedAcronyms.count, 1)
//        
//            let userAcronym = receivedAcronyms.first!
//            XCTAssertEqual(userAcronym.id, acronym.id)
//            XCTAssertEqual(userAcronym.short, acronym.short)
//            XCTAssertEqual(userAcronym.long, acronym.long)
//        })
//    }
//    
//    // MARK: - Private
//    
//    private func generateTestUser() -> User {
//        User(name: "John Doe", username: "JD")
//    }
//}
