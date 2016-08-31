import Vapor
import HTTP
import Foundation

final class CustomerController: ResourceRepresentable {
    
    typealias Item = Customer
    
    // MARK: - Properties
    
    let drop: Droplet
    
    // MARK: - Init
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    // MARK: - REST
    
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

// MARK: - Login / Logout

extension CustomerController {
    
    func login(request: Request) throws -> ResponseRepresentable {
        guard
            let username = request.data["email"].string,
            let password = request.data["password"]?.string
        else {
            throw Abort.custom(status: Status.preconditionFailed, message: "Missing parameter")
        }
        
        guard
            let customer = try Customer.query().filter("email", username).first(),
            let customerID = customer.id
        else {
            throw Abort.custom(status: Status.notImplemented, message: "No Customer")
        }
        
        if customer.password == password {
            
            #if os(Linux)
                let randomUUID = NSUUID().UUIDString
            #else
                let randomUUID = NSUUID().uuidString
            #endif

            guard
                let previousSession = try CustomerSession.query().filter("customer_id", customerID).first()
            else {
                var customerSession = CustomerSession(token: randomUUID, customerID: customerID)
                try customerSession.save()
                return customerSession.makeJSON()
            }
            
            return previousSession.makeJSON()
        }
        
        throw Abort.custom(status: Status.internalServerError, message: "Server Error!")
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        guard
            let token = request.data["token"].string
        else {
            throw Abort.custom(status: Status.preconditionFailed, message: "Missing parameter")
        }
        
        guard
            let previousSession = try CustomerSession.query().filter("token", token).first()
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

// MARK: - Purchases / Vouchers

extension CustomerController {

    func getPurchases(request: Request, customer: Customer) throws -> ResponseRepresentable {
        let allPurchases = try customer.purchases().all()
        let total = allPurchases.reduce(0.0) {$0 + ($1.cashAmount + $1.loyaltyAmount)}
        
        return try JSON([
            "purchases": allPurchases.makeJSON(),
            "total": total
        ])
    }
    
    func getVouchers(request: Request, customer: Customer) throws -> ResponseRepresentable {
        let allVouchers = try customer.vouchers().all()
        let validVouchers = allVouchers.filter { $0.valid }
        let balance = validVouchers.reduce(0.0) {$0 + $1.value}
        
        return try JSON([
            "vouchers": allVouchers.makeJSON(),
            "balance": balance
        ])
    }
    
}
