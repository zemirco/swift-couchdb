
import UIKit

//public class MyDocument: Document {
//    
//    public var city: String!
//    
//    public init(city: String, _id: String?, _rev: String?) {
//        self.city = city
//        super.init(_id: _id, _rev: _rev)
//    }
//    
//    public override init(data: AnyObject) {
//        if let city = data["city"] as? String {
//            self.city = city
//        }
//        super.init(data: data)
//    }
//    
//    public override func serialize() -> [String: AnyObject] {
//        self.dictionary["city"] = self.city
//        return super.serialize()
//    }
//    
//}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        var couchdb = CouchDB(url: "http://localhost:5984", name: nil, password: nil)
        
//        var john = CouchDB.User(name: "john", password: "secret", roles: ["awesome"])
//        couchdb.createUser(john) { response in
//            switch response {
//            case .Error(let error):
//                println(error)
//            case .Success(let res):
//                println(res.id)
//                println(res.ok)
//                println(res.rev)
//            }
//        }
        
//        couchdb.create("tight") { response in
//            switch response {
//            case .Error(let error):
//                println(error)
//            case .Failure(let failure):
//                println(failure.error)
//                println(failure.reason)
//            case .Success(let response):
//                println(response.ok)
//            }
//        }
        
//        couchdb.delete("nice") { response in
//            switch response {
//            case .Error(let error):
//                println(error)
//            case .Success(let res):
//                println(res.ok)
//            }
//        }
        
        // login
//        couchdb.login() { response in
//            switch response {
//            case .Error(let error):
//                println(error)
//            case .Success(let response):
//                println(response)
//                println(response.name)
//                println(response.ok)
//                println(response.roles)
//            }
//        }
        
//        var database = couchdb.use("awesome")
//
        // create document
//        var doc = MyDocument(city: "darmstadt", _id: "tight", _rev: nil)
//        var doc = MyDocument(city: "berlin", _id: nil, _rev: nil)
//        database.post(doc) { response in
//            switch response {
//            case .Error(let error):
//                println(error)
//            case .Success(let res):
//                println(res.id)
//                println(res.ok)
//                println(res.rev)
//            }
//        }
        
        // get document
//        var doc: MyDocument!
//        database.get("tight") { response in
//            switch response {
//            case .Error(let error):
//                println(error)
//            case .Success(let data):
//                println(data)
//                doc = MyDocument(data: data)
//                
//                // edit document
//                doc.city = "Frankfurt"
//                database.put(doc) { response in
//                    switch response {
//                    case .Error(let error):
//                        println(error)
//                    case .Success(let res):
//                        println(res.id)
//                        println(res.ok)
//                        println(res.rev)
//                    }
//                }
                
//                // delete document
//                database.delete(doc) { response in
//                    switch response {
//                    case .Error(let error):
//                        println(error)
//                    case .Success(let res):
//                        println(res.id)
//                        println(res.rev)
//                        println(res.ok)
//                    }
//                }
//            }
//        }
        
//        var citiesByName = "function(doc) {if (doc.city) {emit(doc.city)}}"
//        var myView = View(map: citiesByName, reduce: nil)
//        
//        var design = DesignDocument(_id: "cities", _rev: nil, views: [
//                "citiesByName": myView
//        ])
//        
//        database.put(design) { response in
//            switch response {
//            case .Error(let error):
//                println(error)
//            case .Success(let res):
//                println(res.id)
//                println(res.ok)
//                println(res.rev)
//            }
//            
//        }
        
//        var test = QueryParameters()
//        test.descending = true
//        test.endkey = "awesome"
//        test.keys = ["one", "two", "three"]
//        var q = test.encode()
//        println(q)
//        println(q.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
        
        
//        // query view
//        var view = database.view("cities")
//        
//        var params = QueryParameters()
//        params.limit = 3
//        params.descending = true
//        view.get("citiesByName", query: params) { response in
//            switch response {
//            case .Error(let error):
//                println(error)
//            case .Success(let res):
//                println(res.offset)
//                println(res.total_rows)
//                for row in res.rows {
//                    println(row.id)
//                    println(row.key)
//                }
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

