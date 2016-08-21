import Vapor
import Fluent
import MongoKitten
import HTTP

final class Customer: Model {
    
    var id: Node?
    
    var first: String
    var last: String
    var email: String
    var password: String
    
    init(first: String, last: String, email: String, password: String) {
        self.first = first
        self.last = last
        self.email = email
        self.password = password
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        first = try node.extract("first")
        last = try node.extract("last")
        email = try node.extract("email")
        password = try node.extract("password")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "first": first,
            "last": last,
            "email": email,
            "password": password
        ])
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create("customers") { users in
            users.id()
            users.string("first")
            users.string("last")
            users.string("email")
            users.string("password")
        }
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.delete("customers")
    }
    
}
