import Vapor
import Fluent
import MongoKitten
import HTTP

final class Customer: Model {
    
    static var entity: String = "customer"
    
    var id: Node?
    
    var first: String
    var last: String
    var email: String
    var password: String
    
    init(first: String, last: String, email: String, password: String) {
        self.first = first
        self.last = last
        self.email = email
        self.password = password
    }
    
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

extension Customer {
    
    func purchases() throws -> Children<Purchase> {
        return children()
    }
    
}

extension Customer {
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.customer = self
        return response
    }
    
}

extension Response {
    
    var customer: Customer? {
        get {
            return storage["customer"] as? Customer
        }
        set(customer) {
            storage["customer"] = customer
        }
    }
    
    var customers: [Customer]? {
        get {
            return storage["customers"] as? [Customer]
        }
        set(customers) {
            storage["customers"] = customers
        }
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
