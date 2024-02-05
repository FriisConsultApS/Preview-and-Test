//
//  CLoudCoordinatorTests.swift
//  Preview and TestTests
//
//  Created by Per Friis on 10/10/2023.
//

import XCTest
import SwiftData
@testable import Preview_and_Test

final class CLoudCoordinatorTests: XCTestCase {

    func testUploadTasks() async throws {
        let cloud = CloudCoordinator.preview
        let tasks: [Assignment] = [
            .checkWaterSupply,
            .conductSoilAnalysis
        ]
        do {
            try await cloud.uploadTaskItems(tasks)
        } catch {
            XCTAssert(false, "Error uploading task items")
        }
        
    }

    func testUploadTasksMustFail() async throws {
        let coordinator = CloudCoordinator(ClientFailing())
        let tasks: [Assignment] = [
            .checkWaterSupply,
            .conductSoilAnalysis
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
