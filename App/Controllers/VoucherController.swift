import Vapor
import HTTP

final class VoucherController: ResourceRepresentable {
    
    typealias Item = Voucher
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Voucher.all().makeResponse()
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        guard
            let customerID = request.data["customer_id"].int
        else {
            throw Abort.badRequest
        }
        
        var voucher = Voucher(customerID: Node(customerID))
        
        try voucher.save()
        
        return voucher
    }
    
    func show(request: Request, item voucher: Voucher) throws -> ResponseRepresentable {
        return voucher
    }
    
    func update(request: Request, item voucher: Voucher) throws -> ResponseRepresentable {
        throw Abort.badRequest
    }
    
    func destroy(request: Request, item voucher: Voucher) throws -> ResponseRepresentable {
        throw Abort.badRequest
    }
    
    func makeResource() -> Resource<Voucher> {
        return Resource(
            index: index,
            store: store,
            show: show,
            replace: update,
            destroy: destroy
        )
    }
    
}

extension VoucherController {
    
    var config: VoucherConfig? {
        return (try? VoucherConfig.all())?.first
    }
    
    func getConfig(request: Request) throws -> ResponseRepresentable {
        guard let config = config else { throw Abort.serverError }
        
        if request.accept.prefers("html") {
            return try drop.view("config.mustache", context: [
                "purchase_amount": config.purchaseAmount,
                "voucher_value": config.voucherValue,
                "voucher_duration": config.voucherDuration
            ]).makeResponse()
        } else {
            return config.makeJSON()
        }
    }
    
    func editConfig(request: Request) throws -> ResponseRepresentable {
        guard let config = config else { throw Abort.serverError }
        
        guard
            let purchaseAmount = request.data["purchase_amount"].double,
            let voucherValue = request.data["voucher_value"].double,
            let voucherDuration = request.data["voucher_duration"].int
        else {
            throw Abort.badRequest
        }
        
        var newConfig = config
        
        newConfig.purchaseAmount = purchaseAmount
        newConfig.voucherValue = voucherValue
        newConfig.voucherDuration = voucherDuration
        
        try newConfig.save()
        
        if request.accept.prefers("html") {
            return Response(redirect: "/vouchers/config")
        } else {
            return newConfig.makeJSON()
        }
    }
    
}
