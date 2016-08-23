import Vapor
import Fluent
import MongoKitten
import HTTP

final class CustomerSession: Model {
    
    static var entity: String = "customer_session"
    
    var id: Node?
    var auth_uuid: String
    var customer_id: String
    
    init(authUUID: String, customerID: String) {
        self.auth_uuid = authUUID
        self.customer_id = customerID
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        auth_uuid = try node.extract("auth_uuid")
        customer_id = try node.extract("customer_id")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "auth_uuid": auth_uuid,
            "customer_id": customer_id,
            ])
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create("customer_session") { customerSession in
            customerSession.id()
            customerSession.string("auth_uuid")
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

extension Sequence where Iterator.Element == CustomerSession {
    
    func makeJSON() -> JSON {
        return .array(self.map { $0.makeJSON() })
    }
}
