import Vapor
import Fluent
import HTTP
import Foundation

final class Voucher: Model {
    
    static var entity: String = "voucher"
    
    // MARK: - Properties
    
    var id: Node?
    
    var timestamp: Int
    var expiration: Int
    var value: Double
    
    var redeemed: Int
    
    var userID: Node
    
    var redeemedBool: Bool {
        return redeemed > 0 ? true : false
    }
    var expiredBool: Bool {
        let now = Date()
        let date = Int(now.timeIntervalSince1970)
        return date > expiration
    }
    var valid: Bool {
        return !redeemedBool && !expiredBool
    }
    
    // MARK: - Init
    
    convenience init(userID: Node) throws {
        guard let config = try VoucherConfig.all().first else {
            throw Abort.serverError
        }
        
        let now = Date()
        let future = now + config.voucherDuration
        
        let timestamp = Int(now.timeIntervalSince1970)
        let expiration = Int(future.timeIntervalSince1970)
        let value = config.voucherValue
        
        let redeemed = 0
        
        self.init(timestamp: timestamp, expiration: expiration, value: value, redeemed: redeemed, userID: userID)
    }
    
    init(timestamp: Int, expiration: Int, value: Double, redeemed: Int, userID: Node) {
        self.timestamp = timestamp
        self.expiration = expiration
        self.value = value
        self.redeemed = redeemed
        self.userID = userID
    }
    
    // MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        timestamp = try node.extract("timestamp")
        expiration = try node.extract("expiration")
        value = try node.extract("value")
        redeemed = try node.extract("redeemed")
        userID = try node.extract("user_id")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "timestamp": timestamp,
            "expiration": expiration,
            "value": value,
            "redeemed": redeemed,
            "user_id": userID
        ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { voucher in
            voucher.id()
            voucher.int("timestamp")
            voucher.int("expiration")
            voucher.double("value")
            voucher.int("redeemed")
            voucher.int("user_id")
        }
        
        let sql = "ALTER TABLE voucher ADD CONSTRAINT fk_user_voucher FOREIGN KEY (user_id) REFERENCES user(id);"
        try database.driver.raw(sql)
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
    
}

// MARK: - Relations

extension Voucher {
    
    func user() throws -> Parent<User> {
        return try parent(userID)
    }
    
}

// MARK: - Override

extension Voucher {
    
    public func makeJSON() -> JSON {
        return try! JSON([
            "id": id.int ?? -1,
            "timestamp": timestamp,
            "expiration": expiration,
            "value": value,
            "redeemed": redeemedBool,
            "expired": expiredBool,
            "user_id": userID.int ?? -1
        ] as [String : JSONRepresentable])
    }
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.voucher = self
        return response
    }
    
}

extension Response {
    
    var voucher: Voucher? {
        get { return storage["voucher"] as? Voucher }
        set { storage["voucher"] = newValue }
    }
    
    var vouchers: [Voucher]? {
        get { return storage["vouchers"] as? [Voucher] }
        set { storage["vouchers"] = newValue }
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
