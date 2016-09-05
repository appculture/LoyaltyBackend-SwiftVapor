import Vapor

final class LoyaltyController {
    
    static func makePurchase(userID: Node, totalAmount: Double, voucherIDs: [Polymorphic]?) throws -> Purchase {
        let vouchersAmount = try redeemVouchers(voucherIDs: voucherIDs)
        let cashAmount = totalAmount - vouchersAmount
        
        var purchase = Purchase(cashAmount: cashAmount, loyaltyAmount: vouchersAmount, userID: userID)
        try purchase.save()
        
        try generateVouchers(userID: userID)
        
        return purchase
    }
    
    static func redeemVouchers(voucherIDs: [Polymorphic]?) throws -> Double {
        var vouchersAmount = 0.0
        
        guard let ids = voucherIDs else { return vouchersAmount }
        
        let voucherIntIDs = ids.flatMap({ return $0.int })
        for id in voucherIntIDs {
            if var voucher = try Voucher.query().filter("id", id).first() {
                voucher.redeemed = 1
                try voucher.save()
                vouchersAmount += voucher.value
            }
        }
        
        return vouchersAmount
    }
    
    static func generateVouchers(userID: Node) throws {
        guard
            let user = try User.find(userID),
            let vouchers = try? user.vouchers().all(),
            let purchases = try? user.purchases().all(),
            let config = try VoucherConfig.all().first
        else {
            return
        }
        
        let totalVouchersAmount = vouchers.reduce(0.0) { $0 + $1.value }
        let totalCashPurchaseAmount = purchases.reduce(0.0) { $0 + $1.cashAmount }
        
        let handledCash = ((totalVouchersAmount / config.voucherValue) * config.purchaseAmount)
        var unhandledCash = totalCashPurchaseAmount - handledCash
        
        while unhandledCash >= config.purchaseAmount {
            var voucher = try Voucher(userID: userID)
            try voucher.save()
            unhandledCash -= config.purchaseAmount
        }
    }
    
}
