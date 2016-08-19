import Vapor
import MongoKitten
import HTTP

final class Customer {

    var email: String
    var password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
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
            let email = document["email"].stringValue,
            let password = document["password"].stringValue
        else {
            return nil
        }
        
        self.init(email: email, password: password)
    }
    
}

extension Customer: ResponseRepresentable {
    
    public func makeResponse() throws -> Response {
        let json = try JSON([
            "email": email,
            "password": password
        ])
        
        let response = try Response(status: Status.found, json: json)
        return response
    }
    
}
