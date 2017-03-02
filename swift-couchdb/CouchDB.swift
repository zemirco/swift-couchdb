
import Alamofire

open class CouchDB {
    
    fileprivate var url: String
    fileprivate var headers: [String: String]?
    
    public init(url: String, name: String?, password: String?) {
        self.url = url.hasSuffix("/") ? url : "\(url)/"
        if let name = name, let password = password {
            let auth = "\(name):\(password)"
            let data = auth.data(using: String.Encoding.utf8)
            let base = data!.base64EncodedString(options: [])
            self.headers = [
                "Authorization": "Basic \(base)"
            ]
        }
    }
    
    /**
     * Info
     *
     * http://docs.couchdb.org/en/1.6.1/api/server/common.html#get--
     */
    public struct HTTPInfoResponse {
        public var couchdb: String!
        public var uuid: String!
        public var version: String!
        
        public init(data: Any) {
            if let d = data as? [String: Any] {
                if let
                    couchdb = d["couchdb"] as? String,
                    let uuid = d["uuid"] as? String,
                    let version = d["version"] as? String {
                        self.couchdb = couchdb
                        self.uuid = uuid
                        self.version = version
                }
            }
        }
    }
    
    public enum InfoResponse {
        case success(DataResponse<Any>, HTTPInfoResponse)
        case error(Error)
    }
    
    open func info(_ done: @escaping (InfoResponse) -> Void) {
        Alamofire.request(self.url, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                done(.error(error))
            case .success:
                if let json = response.result.value {
                    done(.success(response, HTTPInfoResponse(data: json)))
                    return
                }
            }
        }
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
    public struct HTTPPostSessionResponse {
        public var ok: Bool!
        public var name: String!
        public var roles: [String]!
        
        public init(data: Any) {
            if let dict = data as? [String: Any] {
                if let
                    ok = dict["ok"] as? Bool,
                    let name = dict["name"] as? String,
                    let roles = dict["roles"] as? [String] {
                        self.ok = ok
                        self.name = name
                        self.roles = roles
                }
            }
        }
    }
    
    public enum LoginResponse {
        case success(DataResponse<Any>, HTTPPostSessionResponse)
        case error(Error)
    }
    
    open func login(_ name: String, password: String, done: @escaping (LoginResponse) -> Void) {
        let data = [
            "name": name,
            "password": password
        ]
        Alamofire.request("\(self.url)_session", method: .post, parameters: data, encoding: JSONEncoding.default, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                done(.error(error))
            case .success:
                if let json = response.result.value {
                    done(.success(response, HTTPPostSessionResponse(data: json)))
                    return
                }
            }
        }
    }
    
    
    
    /**
     * Get session
     * 
     * http://docs.couchdb.org/en/latest/api/server/authn.html#get--_session
     */
    
    // http://docs.couchdb.org/en/latest/json-structure.html#user-context-object
    public struct UserContext {
        public var name: String!
        public var roles: [String]!
        
        public init(data: Any) {
            if let d = data as? [String: Any] {
                if let
                    name = d["name"] as? String,
                    let roles = d["roles"] as? [String] {
                        self.name = name
                        self.roles = roles
                }
            }
        }
    }
    
    public struct HTTPGetSessionResponseInfo {
        public var authenticated: String!
        public var authentication_db: String!
        public var authentication_handlers: [String]!
        
        public init(data: Any) {
            if let d = data as? [String: Any] {
                if let
                    authenticated = d["authenticated"] as? String,
                    let authentication_db = d["authentication_db"] as? String,
                    let authentication_handlers = d["authentication_handlers"] as? [String] {
                        self.authenticated = authenticated
                        self.authentication_db = authentication_db
                        self.authentication_handlers = authentication_handlers
                }
                
            }
        }
    }
    
    public struct HTTPGetSessionResponse {
        public var info: HTTPGetSessionResponseInfo!
        public var ok: Bool!
        public var userCtx: UserContext!
        
        public init(data: Any) {
            if let d = data as? [String: Any] {
                if let
                    info = d["info"] as? [String: Any],
                    let ok = d["ok"] as? Bool,
                    let userCtx = d["userCtx"] as? [String: Any] {
                        self.info = HTTPGetSessionResponseInfo(data: info)
                        self.ok = ok
                        self.userCtx = UserContext(data: userCtx)
                }
            }
        }
    }
    
    public enum GetSessionResponse {
        case success(DataResponse<Any>, HTTPGetSessionResponse)
        case error(Error)
    }
    
    open func getSession(_ done: @escaping (GetSessionResponse) -> Void) {
        Alamofire.request("\(self.url)_session").validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                done(.error(error))
            case .success:
                if let json = response.result.value {
                    done(.success(response, HTTPGetSessionResponse(data: json)))
                    return
                }
            }
        }
    }
    
    
    
    /**
     * Logout
     *
     * http://docs.couchdb.org/en/latest/api/server/authn.html#delete--_session
     */
    public struct HTTPDeleteSessionResponse {
        public var ok: Bool!
        
        public init(data: Any) {
            if let d = data as? [String: Any] {
                if let ok = d["ok"] as? Bool {
                    self.ok = ok
                }
            }
        }
    }
    
    public enum LogoutResponse {
        case success(DataResponse<Any>, HTTPDeleteSessionResponse)
        case error(Error)
    }
    
    open func logout(_ done: @escaping (LogoutResponse) -> Void) {
        Alamofire.request("\(self.url)_session", method: .delete).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                done(.error(error))
            case .success:
                if let json = response.result.value {
                    done(.success(response, HTTPDeleteSessionResponse(data: json)))
                    return
                }
            }
        }
    }
    
    
    
    /**
     * Create database
     *
     * http://docs.couchdb.org/en/latest/api/database/common.html#put--db
     */
    
    public struct HTTPPutCreateSuccess {
        public var ok: Bool!
        
        public init(data: Any) {
            if let dict = data as? [String: Any] {
                if
                    let ok = dict["ok"] as? Bool {
                        self.ok = ok
                }
            }
        }
    }
    
    public enum CreateDatabaseResponse {
        case success(DataResponse<Any>, HTTPPutCreateSuccess)
        case error(Error)
    }
    
    open func createDatabase(_ database: String, done: @escaping (CreateDatabaseResponse) -> Void) {
        Alamofire.request("\(self.url)\(database)", method: .put).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                done(.error(error))
            case .success:
                if let json = response.result.value {
                    done(.success(response, HTTPPutCreateSuccess(data: json)))
                    return
                }
            }
        }
    }
    
    
    
    /**
     * Delete database
     *
     * http://docs.couchdb.org/en/latest/api/database/common.html#delete--db
     */
    
    public struct HTTPDeleteResponse {
        public var ok: Bool!
        
        public init(data: Any) {
            if let dict = data as? [String: Any] {
                if let ok = dict["ok"] as? Bool {
                    self.ok = ok
                }
            }
        }
    }
    
    public enum DeleteDatabaseReponse {
        case success(DataResponse<Any>, HTTPDeleteResponse)
        case error(Error)
    }
    
    open func deleteDatabase(_ database: String, done: @escaping (DeleteDatabaseReponse) -> Void) {
        Alamofire.request("\(self.url)\(database)", method: .delete).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                done(.error(error))
            case .success:
                if let json = response.result.value {
                    done(.success(response, HTTPDeleteResponse(data: json)))
                    return
                }
            }
            
        }
    }
    
    
    
    /**
     * Create user
     */
    
    /**
     * User struct
     * 
     * http://docs.couchdb.org/en/latest/intro/security.html#creating-new-user
     */
    public struct User {
        public var name: String
        public var password: String
        public var roles: [String]
        fileprivate let type: String = "user"
        
        public init(name: String, password: String, roles: [String]) {
            self.name = name
            self.password = password
            self.roles = roles
        }
        
        public func serialize() -> [String: Any] {
            var dict = [String: Any]()
            dict["name"] = name as String?
            dict["password"] = password as String?
            dict["roles"] = roles as [String]?
            dict["type"] = type as String?
            return dict
        }
    }
    
    /**
     * Create user in db
     */
    open func createUser(_ user: User, done: @escaping (Database.PostResponse) -> Void) {
        let data = user.serialize()
        Alamofire.request("\(self.url)_users/org.couchdb.user:\(user.name)", method: .put, parameters: data, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                done(.error(error))
            case .success:
                if let json = response.result.value {
                    done(.success(response, Database.HTTPPostDatabaseReponse(data: json)))
                    return
                }
            }
        }
    }
    
    
    
    /**
     * Use database
     */
    open func use(_ name: String) -> Database {
        return Database(url: "\(self.url)\(name)", headers: self.headers)
    }
    
    
    
    /**
     * Document
     */
    open class Document {
        
        open var dictionary = [String: Any]()
        open var _id: String?
        open var _rev: String?
        
        public init(_id: String?, _rev: String?) {
            self._id = _id
            self._rev = _rev
        }
        
        public init(data: [String: Any]) {
            if let
                _id = data["_id"] as? String,
                let _rev = data["_rev"] as? String {
                    self._id = _id
                    self._rev = _rev
            }
        }
        
        open func serialize() -> [String: Any] {
            self.dictionary["_id"] = self._id as String?
            self.dictionary["_rev"] = self._rev as String?
            return self.dictionary
        }
    }
    
    
    
    /**
     * Design document
     */
    open class DesignDocument: Document {
        
        open let language: String = "javascript"
        open var views: [String: DesignDocumentView]
        
        public init(_id: String?, _rev: String?, views: [String: DesignDocumentView]) {
            self.views = views
            super.init(_id: "_design/\(_id!)", _rev: _rev)
        }
        
        open override func serialize() -> [String : Any] {
            self.dictionary["language"] = language as String?
            var wrapper = [String: Any]()
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
    open class DesignDocumentView {
        open var map: String
        open var reduce: String?
        
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
    open class QueryParameters: QueryString {
        
        open var conflicts: Bool?
        open var descending: Bool?
        open var endkey: String?
        open var endkey_docid: String?
        open var group: Bool?
        open var group_level: Int?
        open var include_docs: Bool?
        open var attachments: Bool?
        open var att_encoding_info: Bool?
        open var inclusive_end: Bool?
        open var key: String?
        open var keys: [String]?
        open var limit: Int?
        open var reduce: Bool?
        open var skip: Int?
        open var stale: String?
        open var startkey: String?
        open var startkey_docid: String?
        open var update_seq: Bool?
        
        public override init() {
            super.init()
        }
        
    }
    
    
    
    /**
     * Database
     */
    open class Database {
        
        fileprivate var url: String
        fileprivate var headers: [String: String]?
        
        public init(url: String, headers: [String: String]?) {
            self.url = url.hasSuffix("/") ? url : "\(url)/"
            self.headers = headers
        }
        
        
        /**
        * Create document
        *
        * http://docs.couchdb.org/en/latest/api/database/common.html#post--db
        */
        public struct HTTPPostDatabaseReponse {
            public var id: String!
            public var ok: Bool!
            public var rev: String!
            
            public init(data: Any) {
                if let dict = data as? [String: Any] {
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
        
        public enum PostResponse {
            case success(DataResponse<Any>, HTTPPostDatabaseReponse)
            case error(Error)
        }
        
        open func post(_ document: Document, done: @escaping (PostResponse) -> Void) {
            Alamofire.request(self.url, method: .post, parameters: document.serialize(), encoding: JSONEncoding.default).validate().responseJSON { response in
                switch response.result {
                case .failure(let error):
                    done(.error(error))
                case .success:
                    if let json = response.result.value {
                        done(.success(response, HTTPPostDatabaseReponse(data: json)))
                        return
                    }
                }
            }
        }
        
        /**
         * Edit document or create new one with id
         *
         * http://docs.couchdb.org/en/latest/api/document/common.html#put--db-docid
         */
        open func put(_ document: Document, done: @escaping (PostResponse) -> Void) {
            Alamofire.request("\(self.url)\(document._id!)", method: .put, parameters: document.serialize(), encoding: JSONEncoding.default).validate().responseJSON { response in
                switch response.result {
                case .failure(let error):
                    done(.error(error))
                case .success:
                    if let json = response.result.value {
                        done(.success(response, HTTPPostDatabaseReponse(data: json)))
                        return
                    }
                }
            }
        }
        
        
        
        /**
         * Delete document
         *
         * http://docs.couchdb.org/en/latest/api/document/common.html#delete--db-docid
         */
        open func delete(_ document: Document, done: @escaping (PostResponse) -> Void) {
            Alamofire.request("\(self.url)\(document._id!)?rev=\(document._rev!)", method: .delete).validate().responseJSON { response in
                switch response.result {
                case .failure(let error):
                    done(.error(error))
                case .success:
                    if let json = response.result.value {
                        done(.success(response, HTTPPostDatabaseReponse(data: json)))
                        return
                    }
                }
            }
        }
        
        
        
        /**
         * Get document
         *
         * http://docs.couchdb.org/en/latest/api/document/common.html#get--db-docid
         */
        public enum GetResponse {
            case success(DataResponse<Any>, Any)
            case error(Error)
        }
        
        
        open func get(_ id: String, done: @escaping (GetResponse) -> Void) {
            Alamofire.request("\(self.url)\(id)").validate().responseJSON { response in
                switch response.result {
                case .failure(let error):
                    done(.error(error))
                case .success:
                    if let json = response.result.value {
                        done(.success(response, json))
                        return
                    }
                }
            }
        }
        
        
        
        /**
         * Create multiple documents with a single request
         *
         * http://docs.couchdb.org/en/latest/api/database/bulk-api.html
         */
        public struct HTTPBulkResponse {
            public var id: String!
            public var rev: String!
            public var error: String?
            public var reason: String?
            
            public init(data: Any) {
                if let dict = data as? [String: Any] {
                    if
                        let id = dict["id"] as? String,
                        let rev = dict["rev"] as? String {
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
            case success(DataResponse<Any>, [HTTPBulkResponse])
            case error(Error)
        }
        
        open func bulk(_ documents: [Document], done: @escaping (BulkResponse) -> Void) {
            let docs = documents.map() { $0.serialize() }
            let data = [
                "docs": docs
            ]
            Alamofire.request("\(self.url)_bulk_docs", method: .post, parameters: data, encoding: JSONEncoding.default).validate().responseJSON { response in
                switch response.result {
                case .failure(let error):
                    done(.error(error))
                case .success:
                    if let json = response.result.value {
                        if let data = json as? [Any] {
                            let arr = data.map() { HTTPBulkResponse(data: $0) }
                            done(.success(response, arr))
                        }
                    }
                }
            }
        }
        
        
        
        /**
         * Use certain view (design document)
         */
        open func view(_ name: String) -> View {
            return View(url: "\(self.url)_design/\(name)/", headers: self.headers)
        }
        
    }
    
    
    
    /**
     * View
     */
    open class View {
        
        /**
         * http://docs.couchdb.org/en/latest/api/ddoc/views.html#get--db-_design-ddoc-_view-view
         */
        public struct GETResponse {
            public var offset: Int!
            public var rows: [Row]!
            public var total_rows: Int!
            public var update_seq: Int!
            
            public init(data: Any) {
                if let dict = data as? [String: Any] {
                    if
                        let offset = dict["offset"] as? Int,
                        let rows = dict["rows"] as? [Any],
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
            public var value: Any!
            public var doc: [String: Any]?
            
            public init(data: Any) {
                if let dict = data as? [String: Any] {
                    if
                        let id = dict["id"] as? String,
                        let key = dict["key"] as? String {
                            self.id = id
                            self.key = key
                            self.value = dict["value"]
                    }
                    if let doc = dict["doc"] as? [String: Any] {
                        self.doc = doc
                    }
                }
            }
        }
        
        fileprivate var url: String
        fileprivate var headers: [String: String]?
        
        public init(url: String, headers: [String: String]?) {
            self.url = url.hasSuffix("/") ? url : "\(url)/"
            self.headers = headers
        }
        
        public enum Response {
            case success(DataResponse<Any>, GETResponse)
            case error(Error)
        }
        
        open func get(_ name: String, query: QueryParameters, done: @escaping (Response) -> Void) {
            let params = query.encode().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            Alamofire.request("\(self.url)_view/\(name)?\(params)", headers: self.headers).validate().responseJSON { response in
                switch response.result {
                case .failure(let error):
                    done(.error(error))
                case .success:
                    if let json = response.result.value {
                        done(.success(response, GETResponse(data: json)))
                        return
                    }
                }
            }
        }
    }
    
    
}














