import Vapor
import HTTP

class CustomerMiddleware: Middleware {
    
    // MARK: - Properties
    
    let drop: Droplet
    
    // MARK: - Init
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    // MARK: - Override

	func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        
        let response = try chain.respond(to: request)
        
        if let customer = response.customer {
            if request.accept.prefers("html") {
                
                let allPurchases = try customer.purchases().all()
                let allVouchers = try customer.vouchers().all()
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
                
                return try drop.view("customer.mustache", context: [
                    "customer_id": customer.id.string ?? "",
                    "first": customer.first,
                    "last": customer.last,
                    "email": customer.email,
                    "purchases": purchases,
                    "all_vouchers": allVouchersDictionary,
                    "valid_vouchers": validVouchersDictionary,
                    "cash_spent" : totalCashPurchaseAmount,
                    "vouchers_redeemed": redeemedVouchersValue,
                    "loyalty_balance": validVouchersValue
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
                            "id": customer.id.string ?? "",
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
