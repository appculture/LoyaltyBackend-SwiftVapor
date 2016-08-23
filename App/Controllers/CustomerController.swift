import Vapor
import HTTP
import Foundation

final class CustomerController: ResourceRepresentable {
    
    typealias Item = Customer
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Customer.all().makeResponse()
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
    
    func login(request: Request) throws -> ResponseRepresentable {
        guard
            let username: String = request.data["email"].string,
            let password: String = request.data["password"]?.string
        else {
            throw Abort.custom(status: Status.preconditionFailed, message: "Missing parameter")
        }
        
        guard
            let customer: Customer = try Customer.query().filter("email", username).first(),
            let customerID = customer.id
        else {
            throw Abort.custom(status: Status.notImplemented, message: "No Customer")
        }
        
        if customer.password == password {
            
            let randomUUID = NSUUID().uuidString

            guard
                let previousSession: CustomerSession = try CustomerSession.query().filter("customer_id", customerID).first()
            else {
                var customerSession: CustomerSession = CustomerSession(token: randomUUID, customerID: customerID)
                try customerSession.save()
                return customerSession.makeJSON()
            }
            
            return previousSession.makeJSON()
        }
        
        throw Abort.custom(status: Status.internalServerError, message: "Server Error!")
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        guard
            let token: String = request.data["token"].string
        else {
            throw Abort.custom(status: Status.preconditionFailed, message: "Missing parameter")
        }
        
        guard
            let previousSession: CustomerSession = try CustomerSession.query().filter("token", token).first()
        else {
            throw Abort.custom(status: Status.internalServerError, message: "Server Error!")
        }
        
        try previousSession.delete()
        
        return try JSON([
            "Status": "OK",
            "Message": "Logout Successful"
        ])
    }
}
