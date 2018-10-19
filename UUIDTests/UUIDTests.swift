//
//  UUIDTests.swift
//  UUID
//
//  Created by WeZZard on 16/01/2017.
//
//

import XCTest

@testable
import struct UUID.UUID


class TestUUID: XCTestCase {
    var rawUUID: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    var uuid: UUID!
    
    internal override func setUp() {
        super.setUp()
        let rawUUIDBytes = withUnsafeMutablePointer(to: &rawUUID, {$0})
            .withMemoryRebound(to: UInt8.self, capacity: 16, {$0})
        uuid_generate_random(rawUUIDBytes)
        uuid = .init(uuid: rawUUID)
    }
    
    internal override func tearDown() {
        super.tearDown()
    }
    
    internal func testRandomAccessCollection() {
        let rawUUIDBytes = withUnsafePointer(to: &rawUUID, {$0})
            .withMemoryRebound(to: UInt8.self, capacity: 16, {$0})
        
        for idx in 0..<16 {
            XCTAssert(rawUUIDBytes[idx] == uuid[idx], "raw UUID byte at index \(idx): \(rawUUIDBytes[idx]) is not equal to UUID byte at index \(idx): \(uuid[idx])")
        }
        
    }
}
