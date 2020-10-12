import Leaf
import Vapor

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get(Paths.acronyms, Acronym.parameter, use: acronymHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req)
            .all()
            .flatMap(to: View.self) { acronyms in
                let acronymsData = acronyms.isEmpty ? nil : acronyms
                let context = IndexContext(
                    title: "Home page",
                    acronyms: acronymsData
                )
                return try req.view().render(Views.index, context)
            }
    }
    
    func acronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self)
            .flatMap(to: View.self) { acronym in
                return acronym.user
                    .get(on: req)
                    .flatMap(to: View.self) { user in
                        let context = AcronymContext(
                            title: acronym.short,
                            acronym: acronym,
                            user: user
                        )
                        return try req.view().render(Views.acronym, context)
                    }
            }
    }
    
    struct Views {
        static let index = "index"
        static let acronym = "acronym"
    }
    
    struct Paths {
        static let acronyms: PathComponent = "acronyms"
    }
}

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
}
