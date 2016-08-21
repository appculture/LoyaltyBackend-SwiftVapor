import Vapor
import HTTP

final class CustomerController: ResourceRepresentable {
    typealias Item = Customer
    
    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let customers = try Customer.all().map { $0.makeJSON() }
        return JSON(customers)
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
        
        try customer.save()
        
        return customer
    }
    
    func show(request: Request, item customer: Customer) throws -> ResponseRepresentable {        
        return customer
    }
    
    func update(request: Request, item customer: Customer) throws -> ResponseRepresentable {
        guard
            let first = request.data["first"].string,
            let last = request.data["last"].string,
            let email = request.data["email"].string,
            let password = request.data["password"].string
        else {
            throw Abort.badRequest
        }
        
        var changedCustomer = customer
        
        changedCustomer.first = first
        changedCustomer.last = last
        changedCustomer.email = email
        changedCustomer.password = password
        
        try changedCustomer.save()
        
        return customer
    }
    
    func destroy(request: Request, item customer: Customer) throws -> ResponseRepresentable {
        try customer.delete()
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

extension CustomerController {
    
    func login(request: Request, item: Customer) throws -> ResponseRepresentable {
        throw Abort.custom(status: Status.notImplemented, message: "Not yet implemented")
    }
    
}
