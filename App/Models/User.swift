
import Vapor
import Fluent
import HTTP

final class User: Model {
    
    static var entity: String = "user"
    
    // MARK: - Properties
    
    var id: Node?
    
    var first: String
    var last: String
    var email: String
    var password: String
    
    // MARK: - Init
    
    init(first: String, last: String, email: String, password: String) {
        self.first = first
        self.last = last
        self.email = email
        self.password = password
    }
    
    // MARK: - NodeConvertible
    
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
    
    // MARK: - Preparation
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { user in
            user.id()
            user.string("first")
            user.string("last")
            user.string("email")
            user.string("password")
        }
        
        var admin = User(first: "System", last: "Root", email: "admin@admin.com", password: "admin")
        try admin.save()
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
    
}

extension Response {
    
    var user: User? {
        get {
            return storage["user"] as? User
        }
        set(user) {
            storage["user"] = user
        }
    }
    
    var users: [User]? {
        get {
            return storage["users"] as? [User]
        }
        set(users) {
            storage["users"] = users
        }
    }
    
}

extension User {
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.user = self
        return response
    }
    
}
