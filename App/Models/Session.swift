import Vapor
import Fluent

final class Session: Model {
    
    static var entity: String = "session"
    
    // MARK: - Properties
    
    var id: Node?
    
    var userID: Node
    var token: String
    
    var cookie: Cookie {
        return Cookie(name: "token", value: token)
    }
    
    // MARK: - Init
    
    init(userID: Node, token: String) {
        self.userID = userID
        self.token = token
    }
    
    // MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        userID = try node.extract("user_id")
        token = try node.extract("token")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": userID,
            "token": token
        ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { session in
            session.id()
            session.string("user_id")
            session.string("token")
        }
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
    
}
