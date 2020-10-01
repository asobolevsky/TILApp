//
//  AppConfigurator.swift
//  
//
//  Created by Aleksei Sobolevskii on 2020-10-01.
//

import Vapor

protocol AppConfiguration {
    var databaseName: String { get }
    var databasePort: Int { get }
}

struct AppConfigurator {
    static func provideConfiguration(for environment: Environment) -> AppConfiguration {
        switch environment {
        case .testing: return TestAppConfiguration()
        default: return DevAppConfiguration()
        }
    }
}
