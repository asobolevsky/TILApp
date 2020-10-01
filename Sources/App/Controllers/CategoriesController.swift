//
//  CategoriesController.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

import Fluent
import Vapor

struct CategoriesController: RouteCollection {
    func getAllHandle(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Category.query(on: req.db).all()
    }
    
    func createHandle(_ req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        return category.save(on: req.db)
            .map { category }
    }
    
    func getHandle(_ req: Request) throws -> EventLoopFuture<Category> {
        Category.find(req.parameters.get(Parameters.categoryID), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func addAcronymHandle(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let categoryQuery = Category.find(req.parameters.get(Parameters.categoryID), on: req.db)
            .unwrap(or: Abort(.notFound))
        let acronymQuery = Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
            .unwrap(or: Abort(.notFound))
        return categoryQuery.and(acronymQuery)
            .flatMap { category, acronym in
                category
                    .$acronyms
                    .attach(acronym, on: req.db)
                    .transform(to: .created)
            }
    }
    
    func removeAcronymHandle(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let categoryQuery = Category.find(req.parameters.get(Parameters.categoryID), on: req.db)
            .unwrap(or: Abort(.notFound))
        let acronymQuery = Acronym.find(req.parameters.get(Parameters.acronymID), on: req.db)
            .unwrap(or: Abort(.notFound))
        return categoryQuery.and(acronymQuery)
            .flatMap { category, acronym in
                category
                    .$acronyms
                    .detach(acronym, on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func getAcronyms(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        Category.find(req.parameters.get(Parameters.categoryID), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                category.$acronyms.query(on: req.db).all()
            }
    }
    
    func boot(routes: RoutesBuilder) throws {
        let baseRoute = routes.grouped(GeneralPaths.api, Paths.categories)
        baseRoute.get(use: getAllHandle)
        baseRoute.post(use: createHandle)
        
        let baseRouteWithID = baseRoute.grouped(":\(Parameters.categoryID)")
        baseRouteWithID.get(use: getHandle)
        baseRouteWithID.post(Paths.acronyms, ":\(Parameters.acronymID)", use: addAcronymHandle)
        baseRouteWithID.delete(Paths.acronyms, ":\(Parameters.acronymID)", use: removeAcronymHandle)
        baseRouteWithID.get(Paths.acronyms, use: getAcronyms)
    }
    
    struct Paths {
        static let categories: PathComponent = "categories"
        static let acronyms: PathComponent = "acronyms"
    }
    
    struct Parameters {
        static let acronymID = "acronymID"
        static let categoryID = "categoryID"
    }
}
