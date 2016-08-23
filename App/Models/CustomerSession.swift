import Vapor
import Fluent
import MongoKitten
import HTTP

final class CustomerSession: Model {
    
    static var entity: String = "customer_session"
    
    var id: Node?
    
    var token: String
    
    var customerID: Node
    
    init(token: String, customerID: Node) {
        self.token = token
        self.customerID = customerID
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        token = try node.extract("token")
        customerID = try node.extract("customer_id")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "token": token,
            "customer_id": customerID,
        ])
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create("customer_session") { customerSession in
            customerSession.id()
            customerSession.string("token")
            customerSession.string("customer_id")
        }
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.delete("customer_session")
    }
    
}

extension CustomerSession {
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.customerSession = self
        return response
    }
    
}

extension Response {
    
    var customerSession: CustomerSession? {
        get {
            return storage["customer_session"] as? CustomerSession
        }
        set(customerSession) {
            storage["customer_session"] = customerSession
        }
    }
    
}
