import Vapor
import HTTP

class VoucherMiddleware: Middleware {
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        
        let response = try chain.respond(to: request)
        
        if let voucher = response.voucher {
            if request.accept.prefers("html") {
                return try drop.view("voucher.mustache", context: [
                    "id": voucher.id?.string ?? "",
                    "timestamp": voucher.timestamp.dateValue.readable,
                    "expiration": voucher.expiration.dateValue.readable,
                    "value": voucher.value,
                    "redeemed": voucher.redeemed > 0 ? "YES" : "NO"
                ]).makeResponse()
            } else {
                response.json = voucher.makeJSON()
            }
        }
        
        if let vouchers = response.vouchers {
            if request.accept.prefers("html") {
                return try drop.view("vouchers.mustache", context: [
                    "vouchers": vouchers.map { voucher -> [String : Any] in
                        return [
                            "id": voucher.id?.string ?? "",
                            "timestamp": voucher.timestamp.dateValue.readable,
                            "expiration": voucher.expiration.dateValue.readable,
                            "value": voucher.value,
                            "redeemed": voucher.redeemed > 0 ? "YES" : "NO"
                        ]
                    }
                ]).makeResponse()
            } else {
                response.json = vouchers.makeJSON()
            }
        }
        
        return response
    }
    
}
