import Vapor
import HTTP

final class ConfigController: ResourceRepresentable {
    
    typealias Item = Config
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        throw Abort.badRequest
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        throw Abort.badRequest
    }
    
    func show(request: Request, item config: Config) throws -> ResponseRepresentable {
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
    
    func update(request: Request, item config: Config) throws -> ResponseRepresentable {
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
        
        return newConfig.makeJSON()
    }
    
    func destroy(request: Request, item config: Config) throws -> ResponseRepresentable {
        throw Abort.badRequest
    }
    
    func makeResource() -> Resource<Config> {
        return Resource(
            index: index,
            store: store,
            show: show,
            replace: update,
            destroy: destroy
        )
    }
    
}
