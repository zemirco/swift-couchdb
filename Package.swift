import PackageDescription

let package = Package(
    name: "swiftCouchdb",
    dependencies: [
        .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4),
        .Package(url: "https://github.com/zemirco/swift-querystring.git", majorVersion: 2)
    ]
)
