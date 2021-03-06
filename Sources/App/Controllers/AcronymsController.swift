//
//  AcronymsController.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-09-30.
//

import Fluent
import Vapor

struct AcronymsController: RouteCollection {
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: req)
    }
    
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self)) { acronym, updatedAcronym in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            acronym.userID = updatedAcronym.userID
            return acronym.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self).delete(on: req).transform(to: .noContent)
    }
    
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req)
            .group(.or) { or in
                or.filter(\.short == searchTerm)
                or.filter(\.long == searchTerm)
            }
            .all()
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    func getSortedHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
    
    func getUserHandler(_ req:Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self).flatMap(to: User.self) { acronym in
            return acronym.user.get(on: req)
        }
    }
    
    func addCategoryHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Acronym.self),
                           req.parameters.next(Category.self)) { acronym, category in
            return acronym.categories.attach(category, on: req).transform(to: .created)
        }
    }
    
    func removeCategoryHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Acronym.self),
                           req.parameters.next(Category.self)) { acronym, category in
            return acronym.categories.detach(category, on: req).transform(to: .noContent)
        }
    }
    
    func getCategoriesHandle(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Acronym.self).flatMap(to: [Category].self) { acronym in
            return try acronym.categories.query(on: req).all()
        }
    }
    
    func boot(router: Router) throws {
        let baseRoute = router.grouped(GeneralPaths.api, Paths.acronyms)
        baseRoute.get(use: getAllHandler)
        baseRoute.post(Acronym.self, use: createHandler)
        baseRoute.get(Paths.first, use: getFirstHandler)
        baseRoute.get(Paths.search, use: searchHandler)
        baseRoute.get(Paths.sorted, use: getSortedHandler)
        
        let baseRouteWithID = baseRoute.grouped(Acronym.parameter)
        baseRouteWithID.get(use: getHandler)
        baseRouteWithID.put(use: updateHandler)
        baseRouteWithID.delete(use: deleteHandler)
        baseRouteWithID.get(Paths.user, use: getUserHandler)
        baseRouteWithID.post(Paths.categories, Category.parameter, use: addCategoryHandler)
        baseRouteWithID.delete(Paths.categories, Category.parameter, use: removeCategoryHandler)
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
}
