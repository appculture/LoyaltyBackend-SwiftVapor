import Vapor
import HTTP

final class ConfigController: ResourceRepresentable {
    
    typealias Item = Config
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Voucher.all().makeResponse()
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        throw Abort.badRequest
    }
    
    func show(request: Request, item voucher: Voucher) throws -> ResponseRepresentable {
        throw Abort.badRequest
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
