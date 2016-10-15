
import Foundation

open class MyDocument: CouchDB.Document {
    
    open var city: String?
    
    public init(city: String, _id: String?, _rev: String?) {
        self.city = city
        super.init(_id: _id, _rev: _rev)
    }
    
    public override init(data: [String: AnyObject]) {
        if let city = data["city"] as? String {
                self.city = city
        }
        super.init(data: data)
    }
    
    open override func serialize() -> [String: AnyObject] {
        self.dictionary["city"] = self.city as AnyObject?
        return super.serialize()
    }
    
}
