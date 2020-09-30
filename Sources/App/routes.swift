import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    // MARK: - Acronyms
    
    app.post("api", "acronyms") { req -> EventLoopFuture<Acronym> in
        let acronym = try req.content.decode(Acronym.self)
        return acronym.save(on: req.db).map {
            acronym
        }
    }

    app.get("api", "acronyms") { req -> EventLoopFuture<[Acronym]> in
        return Acronym.query(on: req.db).all()
    }
    
    app.get("api", "acronyms", ":acronymID") { req -> EventLoopFuture<Acronym> in
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    app.put("api", "acronyms", ":acronymID") { req -> EventLoopFuture<Acronym> in
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
    
    app.delete("api", "acronyms", ":acronymID") { req -> EventLoopFuture<HTTPStatus> in
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
}
