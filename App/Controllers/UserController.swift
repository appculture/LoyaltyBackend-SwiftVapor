import Vapor
import HTTP
import Foundation

final class UserController {
    
    // MARK: - Properties
    
    let drop: Droplet
    
    // MARK: - Init
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    // MARK: - Login / Logout
    
    func login(request: Request) throws -> ResponseRepresentable {
        guard
            let username = request.data["email"]?.string,
            let password = request.data["password"]?.string
        else {
            throw Abort.custom(status: .notFound, message: "User not found!")
        }
        
        guard
            let user = try User.query().filter("email", username).first(),
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
            
            let response = Response(redirect: "/customers")
            let cookie = Cookie(name: "user", value: userID.string!)
            response.cookies.insert(cookie)
            
            guard
                let _ = try UserSession.query().filter("user_id", userID).first()
            else {
                var userSession = UserSession(token: randomUUID, userID: userID)
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
        var userID = ""
        let cookieArray = request.cookies.array
        for cookie in cookieArray {
            if cookie.name == "user" {
                userID = cookie.value
            }
        }
        
        guard
            let previousSession = try UserSession.query().filter("user_id", userID).first()
        else {
            throw Abort.custom(status: Status.internalServerError, message: "Server Error!")
        }
        
        try previousSession.delete()
        
        let response = Response(redirect: "/")
        response.cookies.removeAll()
        return response
    }
    
}
