import Vapor
import Fluent
import HTTP

final class UserSession: Model {
    
    static var entity: String = "user_session"
    
    // MARK: - Properties
    
    var id: Node?
    
    var token: String
    
    var userID: Node
    
    // MARK: - Init
    
    init(token: String, userID: Node) {
        self.token = token
        self.userID = userID
    }
    
    // MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        token = try node.extract("token")
        userID = try node.extract("user_id")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "token": token,
            "user_id": userID,
            ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create("user_session") { userSession in
            userSession.id()
            userSession.string("token")
            userSession.string("user_id")
        }
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.delete("user_session")
    }
    
}

// MARK: - Override

extension UserSession {
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.userSession = self
        return response
    }
    
}

extension Response {
    
    var userSession: UserSession? {
        get {
            return storage["user_session"] as? UserSession
        }
        set(userSession) {
            storage["user_session"] = userSession
        }
    }
    
}
