import Vapor
import HTTP

final class LoginController {
    
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
            throw Abort.badRequest
        }
        
        guard
            let user = try User.query().filter("email", username).first()
        else {
            throw Abort.custom(status: Status.notImplemented, message: "User not found.")
        }
        
        if user.password == password {
            let session = try SessionController.createSession(forUser: user)
            
            let response = Response(redirect: "/users")
            response.cookies.insert(session.cookie)
            
            return response
        }
        else {
            throw Abort.custom(status: Status.internalServerError, message: "Wrong Password.")
        }
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        guard let token = request.token else { throw Abort.badRequest }
        try SessionController.destroySession(withToken: token)
        
        request.cookies.removeAll()
        
        let response = Response(redirect: "/")
        return response
    }
    
}
