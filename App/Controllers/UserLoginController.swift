import Vapor
import HTTP
import Foundation

final class UserLoginController {
    
    // MARK: - Properties
    
    let drop: Droplet
    
    // MARK: - Init
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    // MARK: - Login / Logout
    
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
                let _: UserSession = try UserSession.query().filter("user_id", userID).first()
            else {
                var userSession: UserSession = UserSession(token: randomUUID, userID: userID)
                try userSession.save()
                return response
            }

            return response
        }
        else {
            throw Abort.custom(status: Status.internalServerError, message: "Wrong Password")
        }
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        var userID: String = ""
        let cookieArray: Array = request.cookies.array
        for cookie: Cookie in cookieArray {
            if cookie.name == "user" {
                userID = cookie.value
            }
        }
        
        guard
            let previousSession: UserSession = try UserSession.query().filter("user_id", userID).first()
        else {
            throw Abort.custom(status: Status.internalServerError, message: "Server Error!")
        }
        
        try previousSession.delete()
        
        let response: Response = Response(redirect: "/")
        response.cookies.removeAll()
        return response
    }
    
}
