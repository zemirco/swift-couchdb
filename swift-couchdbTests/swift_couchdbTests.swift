
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
        let expectation = expectationWithDescription("create database")
        let name = "test-create-database"
        couchdb.createDatabase(name) { response in
            switch response {
            case .Error(let error):
                XCTAssertNil(error)
            case .Success(let success):
                XCTAssert(success.ok!)
            }
            self.couchdb.deleteDatabase(name) { _ in
                expectation.fulfill()
            }
            
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testDeleteDatabase() {
        let expectation = expectationWithDescription("delete database")
        let name = "test-delete-database"
        couchdb.createDatabase(name) { _ in
            self.couchdb.deleteDatabase(name) { response in
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
        let name = "test-create-document"
        couchdb.createDatabase(name) { _ in
            let database = self.couchdb.use(name)
            let doc = MyDocument(city: "darmstadt", _id: "home", _rev: nil)
            database.post(doc) { response in
                switch response {
                case .Error(let error):
                    XCTAssertNil(error)
                case .Success(let success):
                    XCTAssert(success.ok!)
                }
                self.couchdb.deleteDatabase(name) { _ in
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testGetDocument() {
        let expectation = expectationWithDescription("get document")
        let name = "test-get-document"
        couchdb.createDatabase(name) { _ in
            let database = self.couchdb.use(name)
            let doc = MyDocument(city: "darmstadt", _id: "home", _rev: nil)
            database.post(doc) { _ in
                database.get("home") { response in
                    switch response {
                    case .Error(let error):
                        XCTAssertNil(error)
                    case .Success(let data):
                        let doc = MyDocument(data: data as! [String : AnyObject])
                        XCTAssertEqual(doc.city, "darmstadt")
                    }
                    self.couchdb.deleteDatabase(name) { _ in
                        expectation.fulfill()
                    }
                }

            }
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testDeleteDocument() {
        let expectation = expectationWithDescription("delete document")
        let name = "test-delete-document"
        couchdb.createDatabase(name) { _ in
            let database = self.couchdb.use(name)
            let doc = MyDocument(city: "darmstadt", _id: nil, _rev: nil)
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
                        self.couchdb.deleteDatabase(name) { _ in
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
        let name = "test-edit-document"
        couchdb.createDatabase(name) { _ in
            let database = self.couchdb.use(name)
            let doc = MyDocument(city: "darmstadt", _id: "edit", _rev: nil)
            database.post(doc) { _ in
                database.get("edit") { response in
                    switch response {
                    case .Error(let error):
                        XCTAssertNil(error)
                    case .Success(let success):
                        let docWithRev = MyDocument(data: success as! [String : AnyObject])
                        docWithRev.city = "frankfurt"
                        database.put(docWithRev) { res in
                            switch res {
                            case .Error(let error):
                                XCTAssertNil(error)
                            case .Success(let success):
                                XCTAssert(success.ok!)
                            }
                            self.couchdb.deleteDatabase(name) { _ in
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
        let berlin = MyDocument(city: "berlin", _id: nil, _rev: nil)
        let frankfurt = MyDocument(city: "frankfurt", _id: nil, _rev: nil)
        let munich = MyDocument(city: "munich", _id: nil, _rev: nil)
        let duesseldorf = MyDocument(city: "duesseldorf", _id: nil, _rev: nil)
        let darmstadt = MyDocument(city: "darmstadt", _id: nil, _rev: nil)
        
        let expectation = expectationWithDescription("bulk documents")
        let name = "bulk-documents"
        
        couchdb.createDatabase(name) { _ in
            let database = self.couchdb.use(name)
            database.bulk([berlin, frankfurt, munich, duesseldorf, darmstadt]) { response in
                switch response {
                case .Error(let error):
                    XCTAssertNil(error)
                case .Success(let data):
                    for datum in data {
                        XCTAssertNotNil(datum.id)
                    }
                }
                self.couchdb.deleteDatabase(name) { _ in
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
    func testCreateDesignDocument() {
        let expectation = expectationWithDescription("create design document")
        let name = "create-design-document"
        
        // create design document
        let map = "function(doc) { if (doc.city) { emit(doc.city) } }"
        let view = CouchDB.DesignDocumentView(map: map, reduce: nil)
        let designDocument = CouchDB.DesignDocument(_id: "cities", _rev: nil, views: [
                "byName": view
        ])
        
        // add document to db
        couchdb.createDatabase(name) { _ in
            let database = self.couchdb.use(name)
            database.put(designDocument) { response in
                switch response {
                case .Error(let error):
                    XCTAssertNil(error)
                case .Success(let success):
                    XCTAssert(success.ok!)
                }
                self.couchdb.deleteDatabase(name) { _ in
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
    }
    
    
    
    func testQueryView() {
        let expectation = expectationWithDescription("query view")
        let name = "test-query-view"
        
        // create design document
        let map = "function(doc) { if (doc.city) { emit(doc.city) } }"
        let view = CouchDB.DesignDocumentView(map: map, reduce: nil)
        let designDocument = CouchDB.DesignDocument(_id: "cities", _rev: nil, views: [
            "byName": view
        ])
        
        // add design document to db
        couchdb.createDatabase(name) { _ in
            let database = self.couchdb.use(name)
            database.put(designDocument) { _ in
                
                // add some dummy documents
                let berlin = MyDocument(city: "berlin", _id: nil, _rev: nil)
                let frankfurt = MyDocument(city: "frankfurt", _id: nil, _rev: nil)
                let munich = MyDocument(city: "munich", _id: nil, _rev: nil)
                let duesseldorf = MyDocument(city: "duesseldorf", _id: nil, _rev: nil)
                let darmstadt = MyDocument(city: "darmstadt", _id: nil, _rev: nil)
                
                database.bulk([berlin, frankfurt, munich, duesseldorf, darmstadt]) { _ in
                    
                    // query view
                    let view = database.view("cities")
                    let params = CouchDB.QueryParameters()
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
                        self.couchdb.deleteDatabase(name) { _ in
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
        
        let john = CouchDB.User(name: "john", password: "secret", roles: ["awesome"])
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
        let john = CouchDB.User(name: "john", password: "secret", roles: ["awesome"])
        couchdb.createUser(john) { _ in
            
            // delete user
            let database = self.couchdb.use("_users")
            database.get("org.couchdb.user:john") { response in
                switch response {
                case .Error(let error):
                    XCTAssertNil(error)
                case .Success(let json):
                    let doc = CouchDB.Document(data: json as! [String : AnyObject])
                    
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
        let steve = CouchDB.User(name: "steve", password: "password", roles: ["awesome"])
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
                let database = self.couchdb.use("_users")
                database.get("org.couchdb.user:steve") { response in
                    switch response {
                    case .Error(let error):
                        XCTAssertNil(error)
                    case .Success(let json):
                        let doc = CouchDB.Document(data: json as! [String : AnyObject])
                        
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
        let wiff = CouchDB.User(name: "wiff", password: "pwd", roles: ["dog"])
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
                    let database = self.couchdb.use("_users")
                    database.get("org.couchdb.user:wiff") { response in
                        switch response {
                        case .Error(let error):
                            XCTAssertNil(error)
                        case .Success(let json):
                            let doc = CouchDB.Document(data: json as! [String : AnyObject])
                            
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
    
    
    
    func testLogout() {
        let expectation = expectationWithDescription("logout")
        
        // create user
        let nitika = CouchDB.User(name: "nitika", password: "pwd", roles: ["dog"])
        couchdb.createUser(nitika) { _ in
            
            // login
            self.couchdb.login("nitika", password: "pwd") { _ in
                
                // make sure user has session
                self.couchdb.getSession() { session in
                    switch session {
                    case .Error(let error):
                        XCTAssertNil(error)
                    case .Success(let success):
                        XCTAssert(success.ok!)
                    }
                    
                    // logout
                    self.couchdb.logout() { response in
                        switch response {
                        case .Error(let error):
                            XCTAssertNil(error)
                        case .Success(let res):
                            XCTAssert(res.ok!)
                        }
                        
                        // delete user
                        let database = self.couchdb.use("_users")
                        database.get("org.couchdb.user:nitika") { response in
                            switch response {
                            case .Error(let error):
                                XCTAssertNil(error)
                            case .Success(let json):
                                let doc = CouchDB.Document(data: json as! [String : AnyObject])
                                
                                database.delete(doc) { _ in
                                    expectation.fulfill()
                                }
                            }
                        }
                        
                    }
                }
                
                
            }
            
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    
    
}
