//
//  UsersController.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-09-30.
//

import Fluent
import Vapor

struct UsersController: RouteCollection {
    func getAllHandle(_ req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    
    func getHandle(_ req: Request) throws -> EventLoopFuture<User> {
        User.find(req.parameters.get(Parameters.userID), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func createHandle(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db)
            .map { user }
    }
    
    func getAcronymsHandle(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        User.find(req.parameters.get(Parameters.userID), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$acronyms.get(on: req.db)
            }
    }
    
    func boot(routes: RoutesBuilder) throws {
        let baseRoute = routes.grouped(GeneralPaths.api, Paths.users)
        baseRoute.get(use: getAllHandle)
        baseRoute.post(use: createHandle)
        
        let baseRouteWithID = baseRoute.grouped(":\(Parameters.userID)")
        baseRouteWithID.get(use: getHandle)
        baseRouteWithID.get(Paths.acronyms, use: getAcronymsHandle)
    }
    
    struct Paths {
        static let users: PathComponent = "users"
        
        static let acronyms: PathComponent = "acronyms"
    }
    
    struct Parameters {
         static let userID = "userID"
    }
}
