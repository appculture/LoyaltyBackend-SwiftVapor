import Vapor
import Fluent
import HTTP

final class CustomerSession: Model {
    
    static var entity: String = "customer_session"
    
    // MARK: - Properties
    
    var id: Node?
    
    var token: String
    
    var customerID: Node
    
    // MARK: - Init
    
    init(token: String, customerID: Node) {
        self.token = token
        self.customerID = customerID
    }
    
    // MARK: - NodeConvertible
    
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
    
    // MARK: - Preparation
    
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
