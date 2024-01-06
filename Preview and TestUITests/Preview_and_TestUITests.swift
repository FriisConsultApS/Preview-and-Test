//
//  Preview_and_TestUITests.swift
//  Preview and TestUITests
//
//  Created by Per Friis on 08/10/2023.
//

import XCTest

final class Preview_and_TestUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddTasks() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        app/*@START_MENU_TOKEN@*/.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"]/*[[".otherElements[\"taskList\"].navigationBars[\"_TtGC7SwiftUI32NavigationStackHosting\"]",".navigationBars[\"_TtGC7SwiftUI32NavigationStackHosting\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Add Item"].tap()
        app/*@START_MENU_TOKEN@*/.collectionViews.staticTexts["Collect soil samples and analyze for nutrient levels and suitability for cultivation."]/*[[".otherElements[\"taskList\"].collectionViews",".cells",".buttons[\"title, Conduct Soil Analysis, due, 13 May 2041, details, Collect soil samples and analyze for nutrient levels and suitability for cultivation.\"].staticTexts[\"Collect soil samples and analyze for nutrient levels and suitability for cultivation.\"]",".staticTexts[\"Collect soil samples and analyze for nutrient levels and suitability for cultivation.\"]",".collectionViews"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.swipeUp()
        
        
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
