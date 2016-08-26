import Vapor
import Fluent
import HTTP

final class Customer: Model {
    
    static var entity: String = "customer"
    
    // MARK: - Properties
    
    var id: Node?
    
    var first: String
    var last: String
    var email: String
    var password: String
    
    // MARK: - Init
    
    init(first: String, last: String, email: String, password: String) {
        self.first = first
        self.last = last
        self.email = email
        self.password = password
    }
    
    // MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        first = try node.extract("first")
        last = try node.extract("last")
        email = try node.extract("email")
        password = try node.extract("password")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "first": first,
            "last": last,
            "email": email,
            "password": password
        ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { customer in
            customer.id()
            customer.string("first")
            customer.string("last")
            customer.string("email")
            customer.string("password")
        }
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
    
}

// MARK: - Relations

extension Customer {
    
    func purchases() throws -> Children<Purchase> {
        return children()
    }
    
    func vouchers() throws -> Children<Voucher> {
        return children()
    }
    
}

// MARK: - Override

extension Customer {
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.customer = self
        return response
    }
    
}

extension Response {
    
    var customer: Customer? {
        get { return storage["customer"] as? Customer }
        set { storage["customer"] = newValue }
    }
    
    var customers: [Customer]? {
        get { return storage["customers"] as? [Customer] }
        set { storage["customers"] = newValue }
    }
    
}

extension Sequence where Iterator.Element == Customer {
    
    func makeJSON() -> JSON {
        return .array(self.map { $0.makeJSON() })
    }

    func makeResponse() throws -> Response {
        let response = Response()
        response.customers = Array(self)
        return response
    }
    
}
