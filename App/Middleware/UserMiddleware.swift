import Vapor
import HTTP

class UserMiddleware: Middleware {
    
    // MARK: - Properties
    
    let drop: Droplet
    
    // MARK: - Init
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    // MARK: - Override
    
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        
        let response = try chain.respond(to: request)
        
        if let user = response.user {
            if request.accept.prefers("html") {
                
                let allPurchases = try user.purchases().all()
                let allVouchers = try user.vouchers().all()
                let redeemedVouchers = allVouchers.filter { $0.redeemedBool }
                let validVouchers = allVouchers.filter { $0.valid }
                
                let totalCashPurchaseAmount = allPurchases.reduce(0.0) { $0 + $1.cashAmount }
                let redeemedVouchersValue = redeemedVouchers.reduce(0.0) { $0 + $1.value }
                let validVouchersValue = validVouchers.reduce(0.0) { $0 + $1.value }
                
                let purchases = allPurchases.map { purchase -> [String : Any] in
                    return [
                        "purchase_id": purchase.id?.string ?? "",
                        "timestamp": purchase.timestamp.dateValue.readable,
                        "cash": purchase.cashAmount,
                        "loyalty": purchase.loyaltyAmount,
                        "total": purchase.cashAmount + purchase.loyaltyAmount
                    ]
                }
                
                let allVouchersDictionary = allVouchers.map { voucher -> [String : Any] in
                    return [
                        "voucher_id": voucher.id?.string ?? "",
                        "timestamp": voucher.timestamp.dateValue.readable,
                        "expiration": voucher.expiration.dateValue.readable,
                        "value": voucher.value,
                        "redeemed": voucher.redeemedBool.readable,
                        "expired": voucher.expiredBool.readable
                    ]
                }
                
                let validVouchersDictionary = validVouchers.map { voucher -> [String : Any] in
                    return [
                        "voucher_id": voucher.id?.string ?? "",
                        "timestamp": voucher.timestamp.dateValue.readable,
                        "expiration": voucher.expiration.dateValue.readable,
                        "value": voucher.value,
                        "redeemed": voucher.redeemedBool.readable,
                        "expired": voucher.expiredBool.readable
                    ]
                }
                
                return try drop.view("user.mustache", context: [
                    "user_id": user.id.string ?? "",
                    "first": user.first,
                    "last": user.last,
                    "email": user.email,
                    "purchases": purchases,
                    "all_vouchers": allVouchersDictionary,
                    "valid_vouchers": validVouchersDictionary,
                    "cash_spent" : totalCashPurchaseAmount,
                    "vouchers_redeemed": redeemedVouchersValue,
                    "loyalty_balance": validVouchersValue
                ]).makeResponse()
                
            } else {
                response.json = user.makeJSON()
            }
        }
        
        if let users = response.users {
            if request.accept.prefers("html") {
                return try drop.view("users.mustache", context: [
                    "users": users.map { user -> [String : Any] in
                        return [
                            "id": user.id.string ?? "",
                            "first": user.first,
                            "last": user.last,
                            "email": user.email
                        ]
                    }
                ]).makeResponse()
            } else {
                response.json = users.makeJSON()
            }
        }
        
        return response
    }
    
}
