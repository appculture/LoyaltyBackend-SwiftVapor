import Vapor
import HTTP

class CustomerMiddleware: Middleware {
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }

	func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        
        let response = try chain.respond(to: request)
        
        if let customer = response.customer {
            if request.accept.prefers("html") {
                
                let purchases = try customer.purchases().all().map { purchase -> [String : Any] in
                    return [
                        "id": purchase.id?.string ?? "",
                        "timestamp": purchase.readableTimestamp,
                        "amount": purchase.amount
                    ]
                }
                
                let vouchers = try customer.vouchers().all().map { voucher -> [String : Any] in
                    return [
                        "id": voucher.id?.string ?? "",
                        "timestamp": voucher.readableTimestamp,
                        "expiration": voucher.readableExpiration,
                        "value": voucher.value,
                        "redeemed": voucher.redeemed > 0 ? "YES" : "NO"
                    ]
                }
                
                return try drop.view("customer.mustache", context: [
                    "id": customer.id?.string ?? "",
                    "first": customer.first,
                    "last": customer.last,
                    "email": customer.email,
                    "purchases": purchases,
                    "vouchers": vouchers
                ]).makeResponse()
                
            } else {
                response.json = customer.makeJSON()
            }
        }
        
        if let customers = response.customers {
            if request.accept.prefers("html") {
                return try drop.view("customers.mustache", context: [
                    "customers": customers.map { customer -> [String : Any] in
                        return [
                            "id": customer.id?.string ?? "",
                            "first": customer.first,
                            "last": customer.last,
                            "email": customer.email
                        ]
                    }
                ]).makeResponse()
            } else {
                response.json = customers.makeJSON()
            }
        }

        return response
	}

}
