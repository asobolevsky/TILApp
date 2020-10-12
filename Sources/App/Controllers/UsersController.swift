//
//  UsersController.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-09-30.
//

import Vapor

struct UsersController: RouteCollection {
    func getAllHandle(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func getHandle(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<User> {
        return User.query(on: req).first().unwrap(or: Abort(.notFound))
    }
    
    func createHandle(_ req: Request, user: User) throws -> Future<User> {
        return user.save(on: req)
    }
    
    func getAcronymsHandle(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self)
            .flatMap(to: [Acronym].self) { user in
                try user.acronyms.query(on: req).all()
            }
    }
    
    func boot(router: Router) throws {
        let baseRoute = router.grouped(GeneralPaths.api, Paths.users)
        baseRoute.get(use: getAllHandle)
        baseRoute.post(User.self, use: createHandle)
        baseRoute.get(Paths.first, use: getFirstHandler)
        
        let baseRouteWithID = baseRoute.grouped(User.parameter)
        baseRouteWithID.get(use: getHandle)
        baseRouteWithID.get(Paths.acronyms, use: getAcronymsHandle)
    }
    
    struct Paths {
        static let users: PathComponent = "users"
        static let first: PathComponent = "first"
        static let acronyms: PathComponent = "acronyms"
    }
}
