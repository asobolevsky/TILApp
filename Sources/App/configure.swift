import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let appConfiguration = AppConfigurator.provideConfiguration(for: app.environment)
    let databasePort = tryUnwrappingPort(from: Environment.get("DATABASE_PORT"), default: appConfiguration.databasePort)
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: databasePort,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? appConfiguration.databaseName
    ), as: .psql)
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateAcronym())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateAcronymCategoryPivot())
    
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
    
    app.logger.logLevel = .debug
}

private func tryUnwrappingPort(from presetValue: String?, default defaultPort: Int) -> Int {
    if let presetPort = Environment.get("DATABASE_PORT") {
        return Int(presetPort) ?? defaultPort
    }
    return defaultPort
}
