//
//  CategoriesController.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

import Fluent
import Vapor

struct CategoriesController: RouteCollection {
    func getAllHandle(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
    func createHandle(_ req: Request, category: Category) throws -> Future<Category> {
        return category.save(on: req)
    }
    
    func getHandle(_ req: Request) throws -> Future<Category> {
        return try req.parameters.next(Category.self)
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Category> {
        return Category.query(on: req)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    func addAcronymHandle(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Category.self),
                           req.parameters.next(Acronym.self)) { category, acronym in
            return category.acronyms.attach(acronym, on: req).transform(to: .created)
        }
    }
    
    func removeAcronymHandle(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Category.self),
                           req.parameters.next(Acronym.self)) { category, acronym in
            return category.acronyms.detach(acronym, on: req).transform(to: .noContent)
        }
    }
    
    func getAcronyms(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(Category.self).flatMap(to: [Acronym].self) { category in
            return try category.acronyms.query(on: req).all()
        }
    }
    
    func boot(router: Router) throws {
        let baseRoute = router.grouped(GeneralPaths.api, Paths.categories)
        baseRoute.get(use: getAllHandle)
        baseRoute.post(Category.self, use: createHandle)
        baseRoute.get(Paths.first, use: getFirstHandler)
        
        let baseRouteWithID = baseRoute.grouped(Category.parameter)
        baseRouteWithID.get(use: getHandle)
        baseRouteWithID.post(Paths.acronyms, Acronym.parameter, use: addAcronymHandle)
        baseRouteWithID.delete(Paths.acronyms, Acronym.parameter, use: removeAcronymHandle)
        baseRouteWithID.get(Paths.acronyms, use: getAcronyms)
    }
    
    struct Paths {
        static let categories: PathComponent = "categories"
        static let acronyms: PathComponent = "acronyms"
        static let first: PathComponent = "first"
    }
}
