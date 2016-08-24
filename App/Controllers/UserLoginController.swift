import Vapor
import HTTP
import Foundation

final class UserLoginController: ResourceRepresentable {
    
    typealias Item = User
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Customer.all().makeResponse()
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
        
        return user
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

extension UserLoginController {
    
    func login(request: Request) throws -> ResponseRepresentable {
       guard
        let username: String = request.data["email"]?.string,
        let password: String = request.data["password"]?.string
        else {
            throw Abort.custom(status: .notFound, message: "User not found!")
        }
        
        guard
            let user: User = try User.query().filter("email", username).first(),
            let userID = user.id
            else {
                throw Abort.custom(status: Status.notImplemented, message: "No Customer")
        }
        
        if user.password == password {
            #if os(Linux)
                let randomUUID = NSUUID().UUIDString
            #else
                let randomUUID = NSUUID().uuidString
            #endif
            
            let response: Response = Response(redirect: "/customers")
            let cookie = Cookie(name: "user", value: userID.string!)
            response.cookies.insert(cookie)
            
            guard
                let previousSession: UserSession = try UserSession.query().filter("user_id", userID).first()
                else {
                    var userSession: UserSession = UserSession(token: randomUUID, userID: userID)
                    try userSession.save()
                    return response
            }
            print(previousSession)
            return response
        }
        else{
            throw Abort.custom(status: Status.internalServerError, message: "Wrong Password")
        }
    }
}
