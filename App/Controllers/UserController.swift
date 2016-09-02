import Vapor
import HTTP
import Foundation

final class UserController: ResourceRepresentable {
    
    typealias Item = User
    
    // MARK: - Properties
    
    let drop: Droplet
    
    // MARK: - Init
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    // MARK: - REST
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try User.all().makeResponse()
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        guard
            let first = request.data["first"].string,
            let last = request.data["last"].string,
            let email = request.data["email"].string,
            let password = request.data["password"].string
        else {
            throw Abort.badRequest
        }
        
        var user = User(first: first, last: last, email: email, password: password)
        try user.save()
        
        return user
    }
    
    func show(request: Request, item user: User) throws -> ResponseRepresentable {
        return user
    }
    
    func update(request: Request, item user: User) throws -> ResponseRepresentable {
        guard
            let first = request.data["first"].string,
            let last = request.data["last"].string,
            let email = request.data["email"].string,
            let password = request.data["password"].string
        else {
            throw Abort.badRequest
        }
        
        var changedUser = user
        
        changedUser.first = first
        changedUser.last = last
        changedUser.email = email
        changedUser.password = password
        
        try changedUser.save()
        
        return changedUser
    }
    
    func destroy(request: Request, item user: User) throws -> ResponseRepresentable {
        try user.delete()
        return user
    }
    
    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: store,
            show: show,
            replace: update,
            destroy: destroy
        )
    }
    
}

// MARK: - Purchases / Vouchers

extension UserController {
    
    func getPurchases(request: Request, user: User) throws -> ResponseRepresentable {
        let allPurchases = try user.purchases().all()
        let total = allPurchases.reduce(0.0) {$0 + ($1.cashAmount + $1.loyaltyAmount)}
        
        return try JSON([
            "purchases": allPurchases.makeJSON(),
            "total": total
        ])
    }
    
    func getVouchers(request: Request, user: User) throws -> ResponseRepresentable {
        let allVouchers = try user.vouchers().all()
        let validVouchers = allVouchers.filter { $0.valid }
        let balance = validVouchers.reduce(0.0) {$0 + $1.value}
        
        return try JSON([
            "vouchers": allVouchers.makeJSON(),
            "balance": balance
        ])
    }
    
}
