
import UIKit
import XCTest
import swift_couchdb

class swift_couchdbTests: XCTestCase {
    
    
    
    private let timeout: NSTimeInterval = 1
    private var couchdb = CouchDB(url: "http://localhost:5984", name: nil, password: nil)
    
    
    
    class MyDocument: Document {
        
        var city: String!
        
        init(city: String, _id: String?, _rev: String?) {
            self.city = city
            super.init(_id: _id, _rev: _rev)
        }
        
        override init(data: AnyObject) {
            if let city = data["city"] as? String {
                self.city = city
            }
            super.init(data: data)
        }
        
        override func serialize() -> [String: AnyObject] {
            self.dictionary["city"] = self.city
            return super.serialize()
        }
        
    }
    
    
    
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
    
    func testCreateDocument() {
        var doc = MyDocument(city: "darmstadt", _id: "home", _rev: nil)
        var database = couchdb.use("test-database")
        let expectation = expectationWithDescription("create document")
        database.post(doc) { response in
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
    
    func testGetDocument() {
        var database = couchdb.use("test-database")
        let expectation = expectationWithDescription("get document")
        database.get("home") { response in
            switch response {
            case .Error(let error):
                XCTAssertNil(error)
            case .Success(let data):
                var doc = MyDocument(data: data)
                XCTAssertEqual(doc.city, "darmstadt")
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
