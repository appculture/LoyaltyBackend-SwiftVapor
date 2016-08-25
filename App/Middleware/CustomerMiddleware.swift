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
                        "timestamp": purchase.timestamp,
                        "amount": purchase.amount
                    ]
                }
                
                return try drop.view("customer.mustache", context: [
                    "id": customer.id?.string ?? "",
                    "first": customer.first,
                    "last": customer.last,
                    "email": customer.email,
                    "purchases": purchases
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
