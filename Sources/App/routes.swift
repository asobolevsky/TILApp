import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        "It works!"
    }

    app.get("hello") { req -> String in
        "Hello, world!"
    }
    
    try app.register(collection: AcronymsController())
    try app.register(collection: CategoriesController())
    try app.register(collection: UsersController())
    
}
