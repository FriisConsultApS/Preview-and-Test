//
//  CLoudCoordinatorTests.swift
//  Preview and TestTests
//
//  Created by Per Friis on 10/10/2023.
//

import XCTest
import CoreData
@testable import Preview_and_Test

final class CLoudCoordinatorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUploadTasks() async throws {
        let coordinator = CloudCoordinator.preview
        let context = NSManagedObjectContext.preview
        let tasks: [TaskItem] = [
            .checkWaterSupply(in: context),
            .conductSoilAnalysis(in: context)
        ]

        try await coordinator.uploadTaskItems(tasks)
    }

    func testUploadTasksMustFail() async throws {
        let coordinator = CloudCoordinator(ClientFailing())
        let context = NSManagedObjectContext.preview
        let tasks: [TaskItem] = [
            .checkWaterSupply(in: context),
            .conductSoilAnalysis(in: context)
        ]
        do {
            try await coordinator.uploadTaskItems(tasks)
            XCTFail("Expeted upload task item to fail")
        } catch ApiError.notAuthorized {
            XCTAssert(true)
        } catch {
            XCTFail("Unexpected error type")
        }
    }



}
