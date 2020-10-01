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
        Acronym.query(on: req.db).all()
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
        Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
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
        Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
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
        Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    func getSortedHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }
    
    func getUserHandler(_ req:Request) throws -> EventLoopFuture<User> {
        Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db)
            }
    }
    
    func addCategoryHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
            .unwrap(or: Abort(.notFound))
        let categoryQuery = Category.find(req.parameters.get(Parameters.categoryID), on: req.db)
            .unwrap(or: Abort(.notFound))
        return acronymQuery.and(categoryQuery)
            .flatMap { acronym, category in
                acronym
                    .$categories
                    .attach(category, on: req.db)
                    .transform(to: .created)
            }
    }
    
    func removeCategoryHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
            .unwrap(or: Abort(.notFound))
        let categoryQuery = Category.find(req.parameters.get(Parameters.categoryID), on: req.db)
            .unwrap(or: Abort(.notFound))
        return acronymQuery.and(categoryQuery)
            .flatMap { acronym, category in
                acronym
                    .$categories
                    .detach(category, on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func getCategoriesHandle(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$categories.query(on: req.db).all()
            }
    }
    
    func boot(routes: RoutesBuilder) throws {
        let baseRoute = routes.grouped(GeneralPaths.api, Paths.acronyms)
        baseRoute.get(use: getAllHandler)
        baseRoute.post(use: createHandler)
        baseRoute.get(Paths.first, use: getFirstHandler)
        baseRoute.get(Paths.search, use: searchHandler)
        baseRoute.get(Paths.sorted, use: getSortedHandler)
        
        let baseRouteWithID = baseRoute.grouped(":\(Parameters.acronymID)")
        baseRouteWithID.get(use: getHandler)
        baseRouteWithID.put(use: updateHandler)
        baseRouteWithID.delete(use: deleteHandler)
        baseRouteWithID.get(Paths.user, use: getUserHandler)
        baseRouteWithID.post(Paths.categories, ":\(Parameters.categoryID)", use: addCategoryHandler)
        baseRouteWithID.delete(Paths.categories, ":\(Parameters.categoryID)", use: removeCategoryHandler)
        baseRouteWithID.get(Paths.categories, use: getCategoriesHandle)
    }
    
    struct Paths {
        static let acronyms: PathComponent = "acronyms"
        
        static let first: PathComponent = "first"
        static let search: PathComponent = "search"
        static let sorted: PathComponent = "sorted"
        static let user: PathComponent = "user"
        
        static let categories: PathComponent = "categories"
    }
    
    struct Parameters {
        static let acronymID = "acronymID"
        static let categoryID = "categoryID"
    }
}
