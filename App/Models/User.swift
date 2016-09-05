import Vapor
import Fluent
import HTTP

enum Role: Int {
    case Admin = 1
    case Customer
}

final class User: Model {
    
    static var entity: String = "user"
    
    // MARK: - Properties
    
    var id: Node?
    
    var first: String
    var last: String
    var email: String
    var password: String
    
    var roleID: Int
    
    var role: Role? {
        return Role(rawValue: roleID)
    }
    
    // MARK: - Init
    
    init(first: String, last: String, email: String, password: String, roleID: Int) {
        self.first = first
        self.last = last
        self.email = email
        self.password = password
        self.roleID = roleID
    }
    
    // MARK: - NodeConvertible
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        first = try node.extract("first")
        last = try node.extract("last")
        email = try node.extract("email")
        password = try node.extract("password")
        roleID = try node.extract("role_id")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "first": first,
            "last": last,
            "email": email,
            "password": password,
            "role_id": roleID
        ])
    }
    
    // MARK: - Preparation
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { user in
            user.id()
            user.string("first")
            user.string("last")
            user.string("email")
            user.string("password")
            user.int("role_id")
        }
        
        try database.driver.raw("ALTER TABLE user ADD CONSTRAINT uc_email UNIQUE (email);")
        
        try addSampleData()
    }
    
    static func revert(_ database: Fluent.Database) throws {
        try database.driver.raw("ALTER TABLE session DROP FOREIGN KEY fk_user_session;")
        try database.driver.raw("ALTER TABLE purchase DROP FOREIGN KEY fk_user_purchase;")
        try database.driver.raw("ALTER TABLE voucher DROP FOREIGN KEY fk_user_voucher;")
        
        try database.delete(entity)
    }
    
    // MARK: - Helpers
    
    static func addSampleData() throws {
        var admin = User(first: "System",
                         last: "Root",
                         email: "admin@admin.com",
                         password: drop.hash.make("admin"),
                         roleID: Role.Admin.rawValue)
        try admin.save()
        
        var customer = User(first: "Test",
                            last: "Customer",
                            email: "test@test.com",
                            password: drop.hash.make("test"),
                            roleID: Role.Customer.rawValue)
        try customer.save()
    }
    
}

// MARK: - Relations

extension User {
    
    func purchases() throws -> Children<Purchase> {
        return children()
    }
    
    func vouchers() throws -> Children<Voucher> {
        return children()
    }
    
}

// MARK: - Override

extension User {
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.user = self
        return response
    }
    
}

extension Response {
    
    var user: User? {
        get { return storage["user"] as? User }
        set { storage["user"] = newValue }
    }
    
    var users: [User]? {
        get { return storage["users"] as? [User] }
        set { storage["users"] = newValue }
    }
    
}

extension Sequence where Iterator.Element == User {
    
    func makeJSON() -> JSON {
        return .array(self.map { $0.makeJSON() })
    }
    
    func makeResponse() throws -> Response {
        let response = Response()
        response.users = Array(self)
        return response
    }
    
}
