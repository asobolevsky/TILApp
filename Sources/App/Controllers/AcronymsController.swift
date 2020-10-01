//
//  AcronymsController.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-09-30.
//

import Fluent
import Vapor

struct AcronymsController: RouteCollection {
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        return Acronym.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(short: data.short,
                              long: data.long,
                              userID: data.userID)
        return acronym.save(on: req.db)
            .map { acronym }
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        return Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updateData = try req.content.decode(CreateAcronymData.self)
        return Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updateData.short
                acronym.long = updateData.long
                acronym.$user.id = updateData.userID
                return acronym.save(on: req.db)
                    .map { acronym }
            }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        //        return Acronym.query(on: req.db)
        //            .filter(\.$short == searchTerm)
        //            .all()
        return Acronym.query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }
            .all()
    }
    
    func getFirstHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        return Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    func getSortedHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        return Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }
    
    func getUserHandler(_ req:Request) throws -> EventLoopFuture<User> {
        return Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db)
            }
    }
    
    func boot(routes: RoutesBuilder) throws {
        let acronymsRoute = routes.grouped(GeneralPaths.api, Paths.acronyms)
        acronymsRoute.get(use: getAllHandler)
        acronymsRoute.post(use: createHandler)
        acronymsRoute.get(Paths.first, use: getFirstHandler)
        acronymsRoute.get(Paths.search, use: searchHandler)
        acronymsRoute.get(Paths.sorted, use: getSortedHandler)
        
        let acronymsRouteWithID = acronymsRoute.grouped(":\(Parameters.acronymID)")
        acronymsRouteWithID.get(use: getHandler)
        acronymsRouteWithID.put(use: updateHandler)
        acronymsRouteWithID.delete(use: deleteHandler)
        acronymsRouteWithID.get(Paths.user, use: getUserHandler)
    }
    
    struct Paths {
        static let acronyms: PathComponent = "acronyms"
        
        static let first: PathComponent = "first"
        static let search: PathComponent = "search"
        static let sorted: PathComponent = "sorted"
        static let user: PathComponent = "user"
    }
    
    struct Parameters {
        static let acronymID = "acronymID"
    }
}
