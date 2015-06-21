
# swift-couchdb

CouchDB client for Swift.

## Installation

1. Install [swift-http](https://github.com/zemirco/swift-http)
2. Copy `CouchDB.swift` from `./swift-couchdb/` into your project.

## Usage

```swift

// create new client
var couchdb = CouchDB(url: "http://localhost:5984", name: nil, password: nil)

// use database
var database = couchdb.use("mydb")

// get document by id
database.get("abc123") { response in
    switch response {
    case .Error(let error):
        println(error)
    case .Success(let data):
        println(data)
    }
}
```

## Test

<kbd>cmd</kbd> + <kbd>u</kbd>

## License

MIT
