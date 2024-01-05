//
//  DemoAppTests.swift
//  DemoAppTests
//
//  Created by hassan uriostegui on 8/30/22.
//

@testable import DemoApp
import SecureVault
import XCTest

class DemoAppTests: XCTestCase {
    struct Token:Codable{
        var count:Int
        var expirationDate:Date
    }
    var secureVault: SecureVault!
    
    override func setUpWithError() throws {
        super.setUp()
        let uuid = UUID().uuidString
        secureVault = SecureVault(namespace: uuid)
       
    }
    
    override func tearDownWithError() throws {
        secureVault = nil
        super.tearDown()
        // Clean up the mock environment here if necessary
    }
    
    func testInitialization() async throws {
        XCTAssertNotNil(secureVault, "SecureVault should be properly initialized.")
    }
    
    func testSetAndGet() async throws {
        let testKey = "testKey"
        let testValue = "testValue"
        
        await secureVault.set(key: testKey, value: testValue)
        let retrievedValue = await secureVault.get(key: testKey)
        
        XCTAssertEqual(retrievedValue, testValue, "The value retrieved should match the value set.")
    }
    
    func testGetWithNonexistentKey() async throws {
        let retrievedValue = await secureVault.get(key: "nonexistentKey")
        XCTAssertNil(retrievedValue, "Getting a value for a nonexistent key should return nil.")
    }
    
    func testOverwritingValueForKey() async throws {
        let testKey = "testKey"
        let initialValue = "initialValue"
        let newValue = "newValue"
        
        await secureVault.set(key: testKey, value: initialValue)
        await secureVault.set(key: testKey, value: newValue)
        let retrievedValue = await secureVault.get(key: testKey)
        
        XCTAssertEqual(retrievedValue, newValue, "The new value should overwrite the initial value.")
    }
    
    func testManyValues() async throws {
        let testKey = "longValue"
        var item=[Token]()
        
        for _ in 0...100000{
            item.append(Token(count: 1, expirationDate: Date()))
        }
        
        let jsonEncoder = JSONEncoder()
        let data = try jsonEncoder.encode(item)
        guard let stringData = String(data: data, encoding: .utf8) else {
            
            fatalError( "Failure building String out of data")
        }
        
        // Start time
        let startTime = Date()
        await secureVault.set(key: testKey, value: stringData)
        // End time
        let endTime = Date()
        // Calculate duration
        let duration = endTime.timeIntervalSince(startTime)
        print("write 100_000 tokens took, \(duration)s")
        
        let retrievedValue = await secureVault.get(key: testKey)
        
        XCTAssertEqual(retrievedValue, stringData, "The new value should overwrite the initial value.")
    }
    
}
