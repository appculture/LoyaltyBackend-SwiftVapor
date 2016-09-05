import Vapor
import Fluent
import HTTP
import Foundation

final class Purchase: Model {
    
    static var entity: String = "purchase"
    
    // MARK: - Properties
    
    var id: Node?
    
    var timestamp: Int
    var cashAmount: Double
    var loyaltyAmount: Double
    
    var userID: Node
    
    // MARK: - Init
    
    convenience init(cashAmount: Double, loyaltyAmount: Double, userID: Node) {
        let timestamp = Int(Date().timeIntervalSince1970)
        self.init(timestamp: timestamp, cashAmount: cashAmount, loyaltyAmount: loyaltyAmount, userID: userID)
    }
    
    init(timestamp: Int, cashAmount: Double, loyaltyAmount: Double, userID: Node) {
        self.timestamp = timestamp
        self.cashAmount = cashAmount
        self.loyaltyAmount = loyaltyAmount
        self.userID = userID
    }
    
    // MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        timestamp = try node.extract("timestamp")
        cashAmount = try node.extract("cash_amount")
        loyaltyAmount = try node.extract("loyalty_amount")
        userID = try node.extract("user_id")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "timestamp": timestamp,
            "cash_amount": cashAmount,
            "loyalty_amount": loyaltyAmount,
            "user_id": userID
        ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { purchase in
            purchase.id()
            purchase.int("timestamp")
            purchase.double("cash_amount")
            purchase.double("loyalty_amount")
            purchase.int("user_id")
        }
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
    
}

// MARK: - Relations

extension Purchase {
    
    func user() throws -> Parent<User> {
        return try parent(userID)
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
        get { return storage["purchase"] as? Purchase }
        set { storage["purchase"] = newValue }
    }
    
    var purchases: [Purchase]? {
        get { return storage["purchases"] as? [Purchase] }
        set { storage["purchases"] = newValue }
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
