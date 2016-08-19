import Vapor
import HTTP

/*
final class CustomerController: ResourceRepresentable {
    typealias Item = Customer
    
    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON([
            "controller": "UserController.index"
        ])
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        return try JSON([
            "controller": "UserController.store"
        ])
    }
    
    /**
    	Since item is of type User,
    	only instances of user will be received
     */
    func show(request: Request, item user: Customer) throws -> ResponseRepresentable {
        //User can be used like JSON with JsonRepresentable
        return try JSON([
            "controller": "UserController.show",
            "user": user
        ])
    }
    
    func update(request: Request, item user: Customer) throws -> ResponseRepresentable {
        //User is JsonRepresentable
        return user.makeJSON()
    }
    
    func destroy(request: Request, item user: Customer) throws -> ResponseRepresentable {
        //User is ResponseRepresentable by proxy of JsonRepresentable
        return user
    }
    
    func makeResource() -> Resource<Customer> {
        return Resource(
            index: index,
            store: store,
            show: show,
            replace: update,
            destroy: destroy
        )
    }
    
}
*/
