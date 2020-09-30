//
//  UsersController.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-09-30.
//

import Fluent
import Vapor

struct UsersController: RouteCollection {
    struct Parameters {
         static let userID = "userID"
    }
    
    func getAllHandle(_ req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }
    
    func getHandle(_ req: Request) throws -> EventLoopFuture<User> {
        return User.find(req.parameters.get(Parameters.userID), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func createHandle(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db)
            .map { user }
    }
    
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api", "users")
        usersRoute.get(use: getAllHandle)
        usersRoute.post(use: createHandle)
        
        let usersRouteWithID = usersRoute.grouped(":\(Parameters.userID)")
        usersRouteWithID.get(use: getHandle)
    }
    
}
