
import Foundation



private let DOMAIN = "CouchDB"



public class CouchDB {
    
    private var url: String
    private var name: String?
    private var password: String?
    
    public init(url: String, name: String?, password: String?) {
        self.url = url.hasSuffix("/") ? url : "\(url)/"
        self.name = name
        self.password = password
    }
    
    /**
     * Login
     *
     * http://docs.couchdb.org/en/latest/api/server/authn.html
     */
    
    /**
    * POST _session response
    *
    * http://docs.couchdb.org/en/latest/api/server/authn.html#post--_session
    */
    public struct POSTSessionResponse {
        public var ok: Bool!
        public var name: String!
        public var roles: [String]!
        
        public init(data: AnyObject) {
            if let dict = data as? [String: AnyObject] {
                if let
                    ok = dict["ok"] as? Bool,
                    name = dict["name"] as? String,
                    roles = dict["roles"] as? [String] {
                        self.ok = ok
                        self.name = name
                        self.roles = roles
                }
            }
        }
    }
    
    public enum LoginResponse {
        case Success(POSTSessionResponse)
        case Error(NSError)
    }
    
    public func login(done: (LoginResponse) -> Void) {
        var data = [
            "name": self.name!,
            "password": self.password!
        ]
        HTTP.post("\(self.url)_session", data: data) { result in
            switch result {
            case .Error(let error):
                done(.Error(error))
            case .Success(let json, let response):
                done(.Success(POSTSessionResponse(data: json)))
            }
        }
    }
    
    
    
    /**
     * Create database
     *
     * http://docs.couchdb.org/en/latest/api/database/common.html#put--db
     */
    
    public struct PUTCreateSuccess {
        public var ok: Bool!
        
        public init(data: AnyObject) {
            if let dict = data as? [String: AnyObject] {
                if
                    let ok = dict["ok"] as? Bool {
                        self.ok = ok
                }
            }
        }
    }
    
    public enum CreateResponse {
        case Success(PUTCreateSuccess)
        case Error(NSError)
    }
    
    public func create(database: String, done: (CreateResponse) -> Void) {
        HTTP.put("\(self.url)\(database)") { response in
            switch response {
            case .Error(let error):
                done(.Error(error))
            case .Success(let json, let res):
                if res.statusCode != 201 {
                    done(.Error(NSError(domain: DOMAIN, code: res.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(res.statusCode)
                        ])))
                    return
                }
                done(.Success(PUTCreateSuccess(data: json)))
            }
        }
    }
    
    
    
    /**
     * Delete database
     *
     * http://docs.couchdb.org/en/latest/api/database/common.html#delete--db
     */
    
    public struct DELETEResponse {
        public var ok: Bool!
        
        public init(data: AnyObject) {
            if let dict = data as? [String: AnyObject] {
                if let ok = dict["ok"] as? Bool {
                    self.ok = ok
                }
            }
        }
    }
    
    public enum DELReponse {
        case Success(DELETEResponse)
        case Error(NSError)
    }
    
    public func delete(database: String, done: (DELReponse) -> Void) {
        HTTP.delete("\(self.url)\(database)") { response in
            switch response {
            case .Error(let error):
                done(.Error(error))
            case .Success(let json, let res):
                if res.statusCode != 200 {
                    done(.Error(NSError(domain: DOMAIN, code: res.statusCode, userInfo: [:])))
                    return
                }
                done(DELReponse.Success(DELETEResponse(data: json)))
            }
            
        }
    }
    
    
    
    /**
     * Use database
     */
    public func use(name: String) -> Database {
        return Database(url: "\(self.url)\(name)")
    }
    
    
    
}



/**
 * Document
 */
public class Document {

    public var dictionary = [String: AnyObject]()
    public var _id: String?
    public var _rev: String?
    
    public init(_id: String?, _rev: String?) {
        self._id = _id
        self._rev = _rev
    }
    
    public init(data: AnyObject) {
        if let
            _id = data["_id"] as? String,
            _rev = data["_rev"] as? String {
                self._id = _id
                self._rev = _rev
        }
    }
    
    public func serialize() -> [String: AnyObject] {
        self.dictionary["_id"] = self._id
        self.dictionary["_rev"] = self._rev
        return self.dictionary
    }
}



/**
 * Design document
 */
public class DesignDocument: Document {
    
    public let language: String = "javascript"
    public var views: [String: DesignDocumentView]
    
    public init(_id: String?, _rev: String?, views: [String: DesignDocumentView]) {
        self.views = views
        super.init(_id: "_design/\(_id!)", _rev: _rev)
    }
    
    public override func serialize() -> [String : AnyObject] {
        self.dictionary["language"] = language
        var wrapper = [String: AnyObject]()
        for (key, value) in self.views {
            var _views = ["map": value.map]
            if let reduce = value.reduce {
                _views["reduce"] = reduce
            }
            wrapper[key] = _views
        }
        self.dictionary["views"] = wrapper
        return super.serialize()
    }
    
}


/**
 * View
 */
public class DesignDocumentView {
    public var map: String
    public var reduce: String?
    
    public init(map: String, reduce: String?) {
        self.map = map
        self.reduce = reduce
    }
    
}



/**
 * Query params
 *
 * http://docs.couchdb.org/en/latest/api/ddoc/views.html#get--db-_design-ddoc-_view-view
 */
public class QueryParameters: QueryString {
    
    public var conflicts: Bool?
    public var descending: Bool?
    public var endkey: String?
    public var endkey_docid: String?
    public var group: Bool?
    public var group_level: Int?
    public var include_docs: Bool?
    public var attachments: Bool?
    public var att_encoding_info: Bool?
    public var inclusive_end: Bool?
    public var key: String?
    public var keys: [String]?
    public var limit: Int?
    public var reduce: Bool?
    public var skip: Int?
    public var stale: String?
    public var startkey: String?
    public var startkey_docid: String?
    public var update_seq: Bool?
    
    public override init() {
        super.init()
    }
    
}



/**
 * Database
 */
public class Database {
    
    private var url: String
    
    public init(url: String) {
        self.url = url.hasSuffix("/") ? url : "\(url)/"
    }
    
    
    /**
     * Create document
     *
     * http://docs.couchdb.org/en/latest/api/database/common.html#post--db
     */
    public struct POSTDatabaseReponse {
        public var id: String!
        public var ok: Bool!
        public var rev: String!
        
        public init(data: AnyObject) {
            if let dict = data as? [String: AnyObject] {
                if
                    let id = dict["id"] as? String,
                    let ok = dict["ok"] as? Bool,
                    let rev = dict["rev"] as? String {
                        self.id = id
                        self.ok = ok
                        self.rev = rev
                }
            }
        }
    }
    
    public enum POSTResponse {
        case Success(POSTDatabaseReponse)
        case Error(NSError)
    }
    
    public func post(document: Document, done: (POSTResponse) -> Void) {
        HTTP.post(self.url, data: document.serialize()) { response in
            switch response {
            case .Error(let error):
                done(.Error(error))
            case .Success(let json, let res):
                if res.statusCode != 201 {
                    done(.Error(NSError(domain: DOMAIN, code: res.statusCode, userInfo: [:])))
                    return
                }
                done(.Success(POSTDatabaseReponse(data: json)))
            }
        }
    }
    
    /**
     * Edit document or create new one with id
     *
     * http://docs.couchdb.org/en/latest/api/document/common.html#put--db-docid
     */
    public func put(document: Document, done: (POSTResponse) -> Void) {
        HTTP.put("\(self.url)\(document._id!)", data: document.serialize()) { response in
            switch response {
            case .Error(let error):
                done(.Error(error))
            case .Success(let json, let res):
                if res.statusCode != 201 {
                    done(.Error(NSError(domain: DOMAIN, code: res.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(res.statusCode)
                    ])))
                    return
                }
                done(.Success(POSTDatabaseReponse(data: json)))
            }
        }
    }
    
    /**
     * Delete document
     *
     * http://docs.couchdb.org/en/latest/api/document/common.html#delete--db-docid
     */
    public func delete(document: Document, done: (POSTResponse) -> Void) {
        HTTP.delete("\(self.url)\(document._id!)?rev=\(document._rev!)") { response in
            switch response {
            case .Error(let error):
                done(.Error(error))
            case .Success(let json, let res):
                if res.statusCode != 200 {
                    done(.Error(NSError(domain: DOMAIN, code: res.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(res.statusCode)
                    ])))
                    return
                }
                done(.Success(POSTDatabaseReponse(data: json)))
            }
        }
    }
    
    /**
     * Get document
     *
     * http://docs.couchdb.org/en/latest/api/document/common.html#get--db-docid
     */
    public enum GETResponse {
        case Success(AnyObject)
        case Error(NSError)
    }
    
    
    public func get(id: String, done: (GETResponse) -> Void) {
        HTTP.get("\(self.url)\(id)") { response in
            switch response {
            case .Error(let error):
                done(GETResponse.Error(error))
            case .Success(let json, let res):
                if res.statusCode != 200 {
                    done(GETResponse.Error(NSError(domain: DOMAIN, code: res.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(res.statusCode)
                    ])))
                    return
                }
                done(GETResponse.Success(json))
            }
        }
    }
    
    /**
     * Create multiple documents with a single request
     * 
     * http://docs.couchdb.org/en/latest/api/database/bulk-api.html
     */
    public struct BulkHTTPResponse {
        public var id: String!
        public var rev: String!
        public var error: String?
        public var reason: String?
        
        public init(data: AnyObject) {
            if let dict = data as? [String: AnyObject] {
                if let
                    id = dict["id"] as? String,
                    rev = dict["rev"] as? String {
                        self.id = id
                        self.rev = rev
                }
                if let error = dict["error"] as? String {
                    self.error = error
                }
                if let reason = dict["reason"] as? String {
                    self.reason = reason
                }
            }
        }
        
    }
    
    public enum BulkResponse {
        case Success([BulkHTTPResponse])
        case Error(NSError)
    }
    
    public func bulk(documents: [Document], done: (BulkResponse) -> Void) {
        var docs = documents.map() { $0.serialize() }
        var data = [
            "docs": docs
        ]
        HTTP.post("\(self.url)_bulk_docs", data: data) { response in
            switch response {
            case .Error(let error):
                done(.Error(error))
            case .Success(let json, let res):
                if res.statusCode != 201 {
                    done(.Error(NSError(domain: DOMAIN, code: res.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(res.statusCode)
                    ])))
                    return
                }
                if let data = json as? [AnyObject] {
                    var arr = data.map() { BulkHTTPResponse(data: $0) }
                    done(.Success(arr))
                }
            }
        }
    }
    
    /**
     * Use certain view (design document)
     */
    public func view(name: String) -> View {
        return View(url: "\(self.url)_design/\(name)/")
    }
    
}



/**
 * View
 */
public class View {
    
    /**
     * http://docs.couchdb.org/en/latest/api/ddoc/views.html#get--db-_design-ddoc-_view-view
     */
    public struct GETResponse {
        public var offset: Int!
        public var rows: [Row]!
        public var total_rows: Int!
        public var update_seq: Int!
        
        public init(data: AnyObject) {
            if let dict = data as? [String: AnyObject] {
                if
                    let offset = dict["offset"] as? Int,
                    let rows = dict["rows"] as? [AnyObject],
                    let total_rows = dict["total_rows"] as? Int {
                        self.offset = offset
                        self.total_rows = total_rows
                        self.rows = []
                        for row in rows {
                            self.rows.append(Row(data: row))
                        }
                }
                if let update_seq = dict["update_seq"] as? Int {
                    self.update_seq = update_seq
                }
            }
        }
    }
    
    public struct Row {
        public var id: String!
        public var key: String!
//        public var value: String!
        
        public init(data: AnyObject) {
            if let dict = data as? [String: AnyObject] {
                if
                    let id = dict["id"] as? String,
                    let key = dict["key"] as? String {
                        self.id = id
                        self.key = key
//                        self.value = value
                }
            }
        }
    }
    
    private var url: String
    
    public init(url: String) {
        self.url = url.hasSuffix("/") ? url : "\(url)/"
    }
    
    public enum Response {
        case Success(GETResponse)
        case Error(NSError)
    }
    
    public func get(name: String, query: QueryParameters, done: (Response) -> Void) {
        var params = query.encode().stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        HTTP.get("\(self.url)_view/\(name)?\(params)") { response in
            switch response {
            case .Error(let error):
                done(.Error(error))
            case .Success(let json, let res):
                println(json)
                done(.Success(GETResponse(data: json)))
            }
        }
    }
}