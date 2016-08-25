import Vapor
import HTTP

class PurchaseMiddleware: Middleware {
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        
        let response = try chain.respond(to: request)
        
        if let purchase = response.purchase {
            if request.accept.prefers("html") {
                return try drop.view("purchase.mustache", context: [
                    "id": purchase.id?.string ?? "",
                    "timestamp": purchase.timestamp.dateValue.readable,
                    "amount": purchase.amount
                ]).makeResponse()
            } else {
                response.json = purchase.makeJSON()
            }
        }
        
        if let purchases = response.purchases {
            if request.accept.prefers("html") {
                return try drop.view("purchases.mustache", context: [
                    "purchases": purchases.map { purchase -> [String : Any] in
                        return [
                            "id": purchase.id?.string ?? "",
                            "timestamp": purchase.timestamp.dateValue.readable,
                            "amount": purchase.amount
                        ]
                    }
                ]).makeResponse()
            } else {
                response.json = purchases.makeJSON()
            }
        }
        
        return response
    }
    
}
