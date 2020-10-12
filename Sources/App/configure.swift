import FluentPostgreSQL
import Leaf
import Vapor

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Register middleware
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a database
    let appConfiguration = AppConfigurator.provideConfiguration(for: env)
    var databases = DatabasesConfig()
    let hostname = Environment.get("DATABASE_HOST") ?? "localhost"
    let databaseName = Environment.get("DATABASE_NAME") ?? appConfiguration.databaseName
    let databasePort = tryUnwrappingPort(from: Environment.get("DATABASE_PORT"), default: appConfiguration.databasePort)
    let username = Environment.get("DATABASE_USERNAME") ?? "vapor_username"
    let password = Environment.get("DATABASE_PASSWORD") ?? "vapor_password"
 
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        port: databasePort,
        username: username,
        database: databaseName,
        password: password
    )
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: DatabaseIdentifier<User.Database>.psql)
    migrations.add(model: Acronym.self, database: DatabaseIdentifier<Acronym.Database>.psql)
    migrations.add(model: Category.self, database: DatabaseIdentifier<Category.Database>.psql)
    migrations.add(model: AcronymCategoryPivot.self, database: DatabaseIdentifier<AcronymCategoryPivot.Database>.psql)
    services.register(migrations)
    
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}

private func tryUnwrappingPort(from presetValue: String?, default defaultPort: Int) -> Int {
    if let presetPort = Environment.get("DATABASE_PORT") {
        return Int(presetPort) ?? defaultPort
    }
    return defaultPort
}
