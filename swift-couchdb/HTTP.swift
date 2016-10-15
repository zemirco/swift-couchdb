
import Foundation



/**
 * HTTP
 */
open class HTTP {
    
    public typealias Response = (Result) -> Void
    public typealias Headers = [String: String]
    
    public enum Method: String {
        case GET    = "GET"
        case POST   = "POST"
        case PUT    = "PUT"
        case HEAD   = "HEAD"
        case DELETE = "DELETE"
    }
    
    public enum Result {
        case success(Any, HTTPURLResponse)
        case error(NSError)
    }
    
    fileprivate var request: URLRequest
    
    
    
    /**
     * Init
     */
    public init(method: Method, url: String) {
        self.request = URLRequest(url: URL(string: url)!)
        self.request.httpMethod = method.rawValue
    }
    
    public init(method: Method, url: String, headers: Headers?) {
        self.request = URLRequest(url: URL(string: url)!)
        self.request.httpMethod = method.rawValue
        if let headers = headers {
            self.request.allHTTPHeaderFields = headers
        }
    }
    
    
    
    /**
     * Class funcs
     */
    
    // GET
    open class func get(_ url: String) -> HTTP {
        return HTTP(method: .GET, url: url)
    }
    
    open class func get(_ url: String, headers: Headers?) -> HTTP {
        return HTTP(method: .GET, url: url, headers: headers)
    }
    
    open class func get(_ url: String, done: @escaping Response) -> HTTP {
        return HTTP.get(url).end(done)
    }
    
    open class func get(_ url: String, headers: Headers?, done: @escaping Response) -> HTTP {
        return HTTP(method: .GET, url: url, headers: headers).end(done)
    }
    
    // POST
    open class func post(_ url: String) -> HTTP {
        return HTTP(method: .POST, url: url)
    }
    
    open class func post(_ url: String, headers: Headers?) -> HTTP {
        return HTTP(method: .POST, url: url, headers: headers)
    }
    
    open class func post(_ url: String, done: @escaping Response) -> HTTP {
        return HTTP.post(url).end(done)
    }
    
    open class func post(_ url: String, data: AnyObject, done: @escaping Response) -> HTTP {
        return HTTP.post(url).send(data).end(done)
    }
    
    open class func post(_ url: String, headers: Headers?, data: AnyObject, done: @escaping Response) -> HTTP {
        return HTTP.post(url, headers: headers).send(data).end(done)
    }
    
    // PUT
    open class func put(_ url: String) -> HTTP {
        return HTTP(method: .PUT, url: url)
    }
    
    open class func put(_ url: String, done: @escaping Response) -> HTTP {
        return HTTP.put(url).end(done)
    }
    
    open class func put(_ url: String, data: AnyObject, done: @escaping Response) -> HTTP {
        return HTTP.put(url).send(data).end(done)
    }
    
    // DELETE
    open class func delete(_ url: String) -> HTTP {
        return HTTP(method: .DELETE, url: url)
    }
    
    open class func delete(_ url: String, done: @escaping Response) -> HTTP {
        return HTTP.delete(url).end(done)
    }
    
    
    
    /**
     * Methods
     */
    open func send(_ data: AnyObject) -> HTTP {
        do {
            self.request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            self.request.httpBody = nil
        }
        self.request.addValue("application/json", forHTTPHeaderField: "Accept")
        self.request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return self
    }
    
    open func end(_ done: @escaping Response) -> HTTP {
        let session = URLSession.shared
        let task = session.dataTask(with: self.request, completionHandler: { data, response, error in
            
            // we have an error -> maybe connection lost
            if let error = error {
                done(Result.error(error as NSError))
                return
            }
            
            // request was success
            var json: Any!
            if let data = data {
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: [])
                } catch let error as NSError {
                    done(Result.error(error))
                    return
                }
            }
            
            // looking good
            let res = response as! HTTPURLResponse
            done(Result.success(json, res))
        }) 
        task.resume()
        return self
    }
    
}
