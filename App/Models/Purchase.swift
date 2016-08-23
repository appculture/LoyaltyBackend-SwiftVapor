import Foundation
import Vapor
import Fluent
import HTTP

final class Purchase: Model {
    
    static var entity: String = "purchase"
    
    var id: Node?
    
    var timestamp: Int
    var amount: Double
    
    convenience init(amount: Double) {
        let timestamp = Int(Date().timeIntervalSince1970)
        self.init(timestamp: timestamp, amount: amount)
    }
    
    init(timestamp: Int, amount: Double) {
        self.timestamp = timestamp
        self.amount = amount
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        timestamp = try node.extract("timestamp")
        amount = try node.extract("amount")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "timestamp": timestamp,
            "amount": amount
        ])
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create("purchase") { purchase in
            purchase.id()
            purchase.int("timestamp")
            purchase.double("amount")
        }
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.delete("purchase")
    }
    
}

extension Purchase {
    
    var date: Date {
        return Date(timeIntervalSince1970: Double(timestamp))
    }
    
    var readableDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
}

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
