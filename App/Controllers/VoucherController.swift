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
