
import UIKit
import XCTest
import swift_couchdb

class swift_couchdbTests: XCTestCase {
    
    
    
    private let timeout: NSTimeInterval = 1
    private var couchdb = CouchDB(url: "http://localhost:5984", name: nil, password: nil)
    
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateDatabase() {
        let expectation = expectationWithDescription("create")
        couchdb.create("test-database") { response in
            switch response {
            case .Error(let error):
                XCTAssertNil(error)
            case .Success(let success):
                XCTAssert(success.ok!)
            }
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testDeleteDatabase() {
        let expectation = expectationWithDescription("delete")
        couchdb.delete("test-database") { response in
            switch response {
            case .Error(let error):
                XCTAssertNil(error)
            case .Success(let success):
                XCTAssert(success.ok!)
            }
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
}
