
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
        let expectation = expectationWithDescription("create database")
        var name = "test-create-database"
        couchdb.createDatabase(name) { response in
            switch response {
            case .Error(let error):
                XCTAssertNil(error)
            case .Success(let success):
                XCTAssert(success.ok!)
            }
            self.couchdb.delete(name) { _ in
                expectation.fulfill()
            }
            
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testDeleteDatabase() {
        let expectation = expectationWithDescription("delete database")
        var name = "test-delete-database"
        couchdb.createDatabase(name) { _ in
            self.couchdb.delete(name) { response in
                switch response {
                case .Error(let error):
                    XCTAssertNil(error)
                case .Success(let success):
                    XCTAssert(success.ok!)
                }
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testCreateDocument() {
        let expectation = expectationWithDescription("create document")
        var name = "test-create-document"
        couchdb.createDatabase(name) { _ in
            var database = self.couchdb.use(name)
            var doc = MyDocument(city: "darmstadt", _id: "home", _rev: nil)
            database.post(doc) { response in
                switch response {
                case .Error(let error):
                    XCTAssertNil(error)
                case .Success(let success):
                    XCTAssert(success.ok!)
                }
                self.couchdb.delete(name) { _ in
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testGetDocument() {
        let expectation = expectationWithDescription("get document")
        var name = "test-get-document"
        couchdb.createDatabase(name) { _ in
            var database = self.couchdb.use(name)
            var doc = MyDocument(city: "darmstadt", _id: "home", _rev: nil)
            database.post(doc) { _ in
                database.get("home") { response in
                    switch response {
                    case .Error(let error):
                        XCTAssertNil(error)
                    case .Success(let data):
                        var doc = MyDocument(data: data)
                        XCTAssertEqual(doc.city, "darmstadt")
                    }
                    self.couchdb.delete(name) { _ in
                        expectation.fulfill()
                    }
                }

            }
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testDeleteDocument() {
        let expectation = expectationWithDescription("delete document")
        var name = "test-delete-document"
        couchdb.createDatabase(name) { _ in
            var database = self.couchdb.use(name)
            var doc = MyDocument(city: "darmstadt", _id: nil, _rev: nil)
            database.post(doc) { res in
                switch res {
                case .Error(let error):
                    XCTAssertNil(error)
                case .Success(let success):
                    doc._id = success.id
                    doc._rev = success.rev
                    database.delete(doc) { success in
                        switch success {
                        case .Error(let error):
                            XCTAssertNil(error)
                        case .Success(let success):
                            XCTAssert(success.ok!)
                        }
                        self.couchdb.delete(name) { _ in
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testEditDocument() {
        let expectation = expectationWithDescription("edit document")
        var name = "test-edit-document"
        couchdb.createDatabase(name) { _ in
            var database = self.couchdb.use(name)
            var doc = MyDocument(city: "darmstadt", _id: "edit", _rev: nil)
            database.post(doc) { _ in
                database.get("edit") { response in
                    switch response {
                    case .Error(let error):
                        XCTAssertNil(error)
                    case .Success(let success):
                        var docWithRev = MyDocument(data: success)
                        docWithRev.city = "frankfurt"
                        database.put(docWithRev) { res in
                            switch res {
                            case .Error(let error):
                                XCTAssertNil(error)
                            case .Success(let success):
                                XCTAssert(success.ok!)
                            }
                            self.couchdb.delete(name) { _ in
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testCreateBulkDocuments() {
        var berlin = MyDocument(city: "berlin", _id: nil, _rev: nil)
        var frankfurt = MyDocument(city: "frankfurt", _id: nil, _rev: nil)
        var munich = MyDocument(city: "munich", _id: nil, _rev: nil)
        var duesseldorf = MyDocument(city: "duesseldorf", _id: nil, _rev: nil)
        var darmstadt = MyDocument(city: "darmstadt", _id: nil, _rev: nil)
        
        let expectation = expectationWithDescription("bulk documents")
        var name = "bulk-documents"
        
        couchdb.createDatabase(name) { _ in
            var database = self.couchdb.use(name)
            database.bulk([berlin, frankfurt, munich, duesseldorf, darmstadt]) { response in
                switch response {
                case .Error(let error):
                    XCTAssertNil(error)
                case .Success(let data):
                    for datum in data {
                        XCTAssertNotNil(datum.id)
                    }
                }
                self.couchdb.delete(name) { _ in
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testCreateDesignDocument() {
        let expectation = expectationWithDescription("create design document")
        var name = "create-design-document"
        
        // create design document
        var map = "function(doc) { if (doc.city) { emit(doc.city) } }"
        var view = DesignDocumentView(map: map, reduce: nil)
        var designDocument = DesignDocument(_id: "cities", _rev: nil, views: [
                "byName": view
        ])
        
        // add document to db
        couchdb.createDatabase(name) { _ in
            var database = self.couchdb.use(name)
            database.put(designDocument) { response in
                switch response {
                case .Error(let error):
                    XCTAssertNil(error)
                case .Success(let success):
                    XCTAssert(success.ok!)
                }
                self.couchdb.delete(name) { _ in
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
    }
    
    
    
    func testQueryView() {
        let expectation = expectationWithDescription("query view")
        var name = "test-query-view"
        
        // create design document
        var map = "function(doc) { if (doc.city) { emit(doc.city) } }"
        var view = DesignDocumentView(map: map, reduce: nil)
        var designDocument = DesignDocument(_id: "cities", _rev: nil, views: [
            "byName": view
        ])
        
        // add design document to db
        couchdb.createDatabase(name) { _ in
            var database = self.couchdb.use(name)
            database.put(designDocument) { _ in
                
                // add some dummy documents
                var berlin = MyDocument(city: "berlin", _id: nil, _rev: nil)
                var frankfurt = MyDocument(city: "frankfurt", _id: nil, _rev: nil)
                var munich = MyDocument(city: "munich", _id: nil, _rev: nil)
                var duesseldorf = MyDocument(city: "duesseldorf", _id: nil, _rev: nil)
                var darmstadt = MyDocument(city: "darmstadt", _id: nil, _rev: nil)
                
                database.bulk([berlin, frankfurt, munich, duesseldorf, darmstadt]) { _ in
                    
                    // query view
                    var view = database.view("cities")
                    var params = QueryParameters()
                    params.limit = 3
                    params.descending = true
                    view.get("byName", query: params) { response in
                        switch response {
                        case .Error(let error):
                            XCTAssertNil(error)
                        case .Success(let response):
                            XCTAssertEqual(response.rows.count, 3)
                            XCTAssertEqual(response.rows[0].key, "munich")
                        }
                        self.couchdb.delete(name) { _ in
                            expectation.fulfill()
                        }
                    }
                    
                }
                
            }
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testCreateUser() {
        let expectation = expectationWithDescription("create user")
        
        var john = CouchDB.User(name: "john", password: "secret", roles: ["awesome"])
        couchdb.createUser(john) { response in
            switch response {
            case .Error(let error):
                XCTAssertNil(error)
            case .Success(let res):
                XCTAssert(res.ok!)
            }
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testDeleteUser() {
        let expectation = expectationWithDescription("delete user")
        
        // create user
        var john = CouchDB.User(name: "john", password: "secret", roles: ["awesome"])
        couchdb.createUser(john) { _ in
            
            // delete user
            var database = self.couchdb.use("_users")
            database.get("org.couchdb.user:john") { response in
                switch response {
                case .Error(let error):
                    XCTAssertNil(error)
                case .Success(let json):
                    var doc = Document(data: json)
                    
                    database.delete(doc) { res in
                        switch res {
                        case .Error(let error):
                            XCTAssertNil(error)
                        case .Success(let success):
                            XCTAssert(success.ok!)
                        }
                        expectation.fulfill()
                    }
                    
                }
            }
            
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testLogin() {
        let expectation = expectationWithDescription("login")
        
        // create user first
        var steve = CouchDB.User(name: "steve", password: "password", roles: ["awesome"])
        couchdb.createUser(steve) { _ in
            
            // test login
            self.couchdb.login("steve", password: "password") { response in
                switch response {
                case .Error(let error):
                    XCTAssertNil(error)
                case .Success(let success):
                    XCTAssert(success.ok!)
                }
                
                // delete user
                var database = self.couchdb.use("_users")
                database.get("org.couchdb.user:steve") { response in
                    switch response {
                    case .Error(let error):
                        XCTAssertNil(error)
                    case .Success(let json):
                        var doc = Document(data: json)
                        
                        database.delete(doc) { _ in
                            expectation.fulfill()
                        }
                    }
                }
            }
            
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testGetSession() {
        let expectation = expectationWithDescription("get session")
        
        // create user
        var wiff = CouchDB.User(name: "wiff", password: "pwd", roles: ["dog"])
        couchdb.createUser(wiff) { _ in
            
            // login
            self.couchdb.login("wiff", password: "pwd") { _ in
                
                // get session
                self.couchdb.getSession() { response in
                    
                    switch response {
                    case .Error(let error):
                        XCTAssertNil(error)
                    case .Success(let res):
                        XCTAssertEqual(res.info.authenticated, "cookie")
                        XCTAssertEqual(res.userCtx.roles, ["dog"])
                        XCTAssert(res.ok!)
                    }
                    
                    // delete user
                    var database = self.couchdb.use("_users")
                    database.get("org.couchdb.user:wiff") { response in
                        switch response {
                        case .Error(let error):
                            XCTAssertNil(error)
                        case .Success(let json):
                            var doc = Document(data: json)
                            
                            database.delete(doc) { _ in
                                expectation.fulfill()
                            }
                        }
                    }
                    
                }
                
            }
            
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
//    func testLogout() {
//        let expectation = expectationWithDescription("logout")
//        
//        // create user
//        var nitika = CouchDB.User(name: "nitika", password: "pwd", roles: ["dog"])
//        couchdb.createUser(nitika) { _ in
//            
//            // login
//            self.couchdb.login("nitika", password: "pwd") { _ in
//                
//                // logout
//                
//                
//            }
//            
//        }
//        
//        waitForExpectationsWithTimeout(timeout, handler: nil)
//    }
    
    
    
}
