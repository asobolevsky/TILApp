@testable import App
import XCTVapor

/*
 docker-compose -f docker-compose-testing.yml build
 
 docker-compose -f docker-compose-testing.yml up \
    --abort-on-container-exit
 */

final class AppTests: XCTestCase {
    func testHelloWorld() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }
}
