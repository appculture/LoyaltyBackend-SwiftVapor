import Foundation
import Vapor
import Fluent
import HTTP

final class Voucher: Model {
    
    static var entity: String = "voucher"
    
    var id: Node?
    
    var timestamp: Int
    var expiration: Int
    var value: Double
    var redeemed: Bool
    
    var customerID: Node
    
    convenience init(customerID: Node) {
        let now = Date()
        let timestamp = Int(now.timeIntervalSince1970)
        let expiration = Int(now.addingTimeInterval(360).timeIntervalSince1970)
        let value = 5.0
        let redeemed = false
        self.init(timestamp: timestamp, expiration: expiration, value: value, redeemed: redeemed, customerID: customerID)
    }
    
    init(timestamp: Int, expiration: Int, value: Double, redeemed: Bool, customerID: Node) {
        self.timestamp = timestamp
        self.expiration = expiration
        self.value = value
        self.redeemed = redeemed
        self.customerID = customerID
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        timestamp = try node.extract("timestamp")
        expiration = try node.extract("expiration")
        value = try node.extract("value")
        redeemed = try node.extract("redeemed")
        customerID = try node.extract("customer_id")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "timestamp": timestamp,
            "expiration": expiration,
            "value": value,
            "redeemed": redeemed,
            "customer_id": customerID
        ])
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { voucher in
            voucher.id()
            voucher.int("timestamp")
            voucher.int("expiration")
            voucher.double("value")
            voucher.bool("redeemed")
            voucher.int("customer_id")
        }
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
    
}

extension Voucher {
    
    func customer() throws -> Parent<Customer> {
        return try parent(customerID)
    }
    
}

extension Voucher {
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.voucher = self
        return response
    }
    
}

extension Response {
    
    var voucher: Voucher? {
        get {
            return storage["voucher"] as? Voucher
        }
        set(purchase) {
            storage["voucher"] = voucher
        }
    }
    
    var vouchers: [Voucher]? {
        get {
            return storage["vouchers"] as? [Voucher]
        }
        set(vouchers) {
            storage["vouchers"] = vouchers
        }
    }
    
}

extension Sequence where Iterator.Element == Voucher {
    
    func makeJSON() -> JSON {
        return .array(self.map { $0.makeJSON() })
    }
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.vouchers = Array(self)
        return response
    }
    
}
