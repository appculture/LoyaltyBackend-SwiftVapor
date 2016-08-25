import Vapor
import Fluent
import HTTP
import Foundation

final class Purchase: Model {
    
    static var entity: String = "purchase"
    
    // MARK: - Properties
    
    var id: Node?
    
    var timestamp: Int
    var amount: Double
    
    var customerID: Node
    
    // MARK: - Init
    
    convenience init(amount: Double, customerID: Node) {
        let timestamp = Int(Date().timeIntervalSince1970)
        self.init(timestamp: timestamp, amount: amount, customerID: customerID)
    }
    
    init(timestamp: Int, amount: Double, customerID: Node) {
        self.timestamp = timestamp
        self.amount = amount
        self.customerID = customerID
    }
    
    // MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        timestamp = try node.extract("timestamp")
        amount = try node.extract("amount")
        customerID = try node.extract("customer_id")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "timestamp": timestamp,
            "amount": amount,
            "customer_id": customerID
        ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { purchase in
            purchase.id()
            purchase.int("timestamp")
            purchase.double("amount")
            purchase.int("customer_id")
        }
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
    
}

// MARK: - Relations

extension Purchase {
    
    func customer() throws -> Parent<Customer> {
        return try parent(customerID)
    }
    
}

// MARK: - Override

extension Purchase {
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.purchase = self
        return response
    }
    
}

extension Response {
    
    var purchase: Purchase? {
        get {
            return storage["purchase"] as? Purchase
        }
        set(purchase) {
            storage["purchase"] = purchase
        }
    }
    
    var purchases: [Purchase]? {
        get {
            return storage["purchases"] as? [Purchase]
        }
        set(purchases) {
            storage["purchases"] = purchases
        }
    }
    
}

extension Sequence where Iterator.Element == Purchase {
    
    func makeJSON() -> JSON {
        return .array(self.map { $0.makeJSON() })
    }
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.purchases = Array(self)
        return response
    }
    
}
