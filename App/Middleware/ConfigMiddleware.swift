import Vapor
import HTTP

class ConfigMiddleware: Middleware {
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        
        let response = try chain.respond(to: request)
        
        if let config = response.config {
            if request.accept.prefers("html") {
                return try drop.view("config.mustache", context: [
                    "id": config.id?.string ?? "",
                    "purchase_amount": config.purchaseAmount,
                    "voucher_value": config.voucherValue,
                    "voucher_duration": config.voucherDuration
                ]).makeResponse()
            } else {
                response.json = config.makeJSON()
            }
        }
        
        return response
    }
    
}
