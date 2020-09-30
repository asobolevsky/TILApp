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
        let acronym = try req.content.decode(Acronym.self)
        return acronym.save(on: req.db).map {
            acronym
        }
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updatedAcronym = try req.content.decode(Acronym.self)
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updatedAcronym.short
                acronym.long = updatedAcronym.long
                return acronym.save(on: req.db).map {
                    acronym
                }
            }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
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
        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$short == searchTerm)
            or.filter(\.$long == searchTerm)
        }.all()
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
    
    func boot(routes: RoutesBuilder) throws {
        let generalAcronymsRoute = routes.grouped("api", "acronyms")
        generalAcronymsRoute.get(use: getAllHandler)
        generalAcronymsRoute.post(use: createHandler)
        generalAcronymsRoute.get("first", use: getFirstHandler)
        generalAcronymsRoute.get("search", use: searchHandler)
        generalAcronymsRoute.get("sorted", use: getSortedHandler)
        
        let acronymsRouteWithID = generalAcronymsRoute.grouped(":acronymID")
        acronymsRouteWithID.get(":acronymID", use: getHandler)
        acronymsRouteWithID.put(":acronymID", use: updateHandler)
        acronymsRouteWithID.delete(":acronymID", use: deleteHandler)
    }
}
