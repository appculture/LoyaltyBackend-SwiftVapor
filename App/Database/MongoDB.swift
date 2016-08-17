import Vapor
import MongoKitten

class MongoDB {
    static let shared = MongoDB(username: Env.MongoUsername, password: Env.MongoPassword, host: Env.MongoHost, port: Env.MongoPort)!

    var server: MongoKitten.Server
    var db: MongoKitten.Database

    var Customer: MongoKitten.Collection

    init?(username: String, password: String, host: String, port: String) {
        do {
            server = try Server("mongodb://\(username):\(password)@\(host):\(port)", automatically: true)
            db = server[Env.MongoDbName]

            Customer = db["Customer"]

        } catch {
            print("MongoDB is not available on the given host and port")
            return nil
        }
    }
}

struct Env {
    static let MongoUsername = drop.config["app", "MONGO_USERNAME"].string!
    static let MongoPassword = drop.config["app", "MONGO_PASSWORD"].string!
    static let MongoHost = drop.config["app", "MONGO_HOST"].string!
    static let MongoPort = drop.config["app", "MONGO_PORT"].string!
    static let MongoDbName = drop.config["app", "MONGO_DB_NAME"].string!
}
