import Vapor
import Fluent
import MongoKitten
import HTTP

/// - NOTE: User is just temporary here for testing
final class User: Model {
    var id: Node?
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "name": name
        ])
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        //
    }
    
    static func revert(_ database: Fluent.Database) throws {
        //
    }
}


final class Customer: Model, Entity {
    
    /**
     The entity's primary identifier.
     This is the same value used for
     `find(:_)`.
    */
    public var id: Node?

    var first: String
    var last: String
    var email: String
    var password: String
    
    init(first: String, last: String, email: String, password: String) {
        id = nil
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
    
    /*
    public func save() throws {
        print("hi")
        var customerDocument: Document = [
            "first": first,
            "last": last,
            "email": email,
            "password": password
        ]
        
        let inserted = try MongoDB.shared.Customer.insert(customerDocument)
        self.id = inserted.id
    }
    */
    
}

extension Customer: Preparation {
    
    /**
     The revert method should undo any actions
     caused by the prepare method.
     
     If this is impossible, the `PreparationError.revertImpossible`
     error should be thrown.
     */
    public static func revert(_ database: Fluent.Database) throws {
        throw PreparationError.revertImpossible
    }

    /**
     The prepare method should call any methods
     it needs on the database to prepare.
     */
    public static func prepare(_ database: Fluent.Database) throws {
        //
    }
    
}

extension Customer: NodeConvertible {
    
    /**
     Initialize the convertible with a node within a context.
     
     Context is an empty protocol to which any type can conform.
     This allows flexibility. for objects that might require access
     to a context outside of the node ecosystem
 
    public convenience init(node: Node, in context: Context) throws {
        
        id = try node.extract("id")
        email = try node.extract("email")
        password = try node.extract("password")
    }*/
    
    /**
     Turn the convertible into a node
     
     - throws: if convertible can not create a Node
     - returns: a node if possible
     */
    
    public func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "first": first,
            "last": last,
            "email": email,
            "password": password
        ])
    }

}

extension Customer: JSONRepresentable {
    
    func makeJSON() throws -> JSON {
        do {
            return try JSON([
                "email": "\(email)",
                "password": "\(password)"
            ])
        } catch {
            throw error
        }
    }
    
}

extension Customer: StringInitializable {
    
    convenience init?(from string: String) throws {
        self.init(email: string)
    }
    
    convenience init?(email: String) {
        do {
            guard let customer = try MongoDB.shared.Customer.findOne(matching: ["email": ~email]) else {
                print("Failed to find customer for email: \(email)")
                return nil
            }
            self.init(document: customer)
        }
        catch {
            print("Failed to find customer for email: \(email)")
            return nil
        }
    }
    
    convenience init?(document: Document) {
        guard
            let first = document["first"].stringValue,
            let last = document["last"].stringValue,
            let email = document["email"].stringValue,
            let password = document["password"].stringValue
        else {
            return nil
        }
        
        self.init(first: first, last: last, email: email, password: password)
    }
    
}

extension Customer: ResponseRepresentable {
    
    public func makeResponse() throws -> Response {
        let json = try JSON([
            //"id": id,
            "first": first,
            "last": last,
            "email": email,
            "password": password
        ])
        
        let response = try Response(status: Status.found, json: json)
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
