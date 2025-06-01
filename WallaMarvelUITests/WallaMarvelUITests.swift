import XCTest
import XCTest

class WallaMarvelUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testHeroesListLoadsSuccessfully() throws {
        let app = XCUIApplication()
        app.launch()

        let heroList = app.tables["heroesTableView"]
        let exists = heroList.waitForExistence(timeout: 5)

        XCTAssertTrue(exists, "Heroes list should exist")
        XCTAssertTrue(heroList.cells.count > 0, "Heroes list should have items")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
