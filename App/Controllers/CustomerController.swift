import Vapor
import HTTP

final class CustomerController: ResourceRepresentable {
    typealias Item = Customer
    
    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON([
            "controller": "CustomerController.index"
        ])
        
        // return JSON(try Customer.all().map { $0.makeJSON() })
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        guard
            let first = request.data["first"].string,
            let last = request.data["last"].string,
            let email = request.data["email"].string,
            let password = request.data["password"].string
        else {
            throw Abort.badRequest
        }
        
        var customer = Customer(first: first, last: last, email: email, password: password)
        
        do {
            try customer.save()
        } catch {
            print(error)
        }
        
        return customer
    }
    
    /**
    	Since item is of type User,
    	only instances of user will be received
     */
    func show(request: Request, item customer: Customer) throws -> ResponseRepresentable {
        //User can be used like JSON with JsonRepresentable
        return try JSON([
            "controller": "CustomerController.show",
            "customer": customer
        ])
    }
    
    func update(request: Request, item customer: Customer) throws -> ResponseRepresentable {
        //User is JsonRepresentable
        return try customer.makeJSON()
    }
    
    func destroy(request: Request, item customer: Customer) throws -> ResponseRepresentable {
        //User is ResponseRepresentable by proxy of JsonRepresentable
        return customer
    }
    
    func makeResource() -> Resource<Customer> {
        return Resource(
            index: index,
            store: store,
            show: show,
            replace: update,
            destroy: destroy
        )
    }
    
}
