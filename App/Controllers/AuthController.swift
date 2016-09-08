import Vapor
import HTTP

final class AuthController {
    
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
            let user = try User.query().filter("email", username).first(),
            let role = user.role
        else {
            throw Abort.custom(status: Status.forbidden, message: "User not found.")
        }
        
        let hashedPassword = drop.hash.make(password)
        guard user.password == hashedPassword
        else {
            throw Abort.custom(status: Status.forbidden, message: "Password incorrect.")
        }
        
        let session = try SessionController.establishSession(forUser: user)
        let jsonResponse = try JSON([
            "user_id": user.id?.int ?? -1,
            "token": session.token
        ])
        
        if request.accept.prefers("html") {
            switch role {
            case .Admin:
                let response = Response(redirect: "/users")
                response.cookies.insert(session.cookie)
                return response
            case .Customer:
                throw Abort.custom(status: Status.forbidden, message: "Access denied.")
            }
        } else {
            return jsonResponse
        }
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        guard let token = request.token else { throw Abort.badRequest }
        try SessionController.destroySession(withToken: token)
        
        /// - NOTE: Removing cookies is not working in Vapor 0.16.2.
        request.cookies.removeAll()
        
        if request.accept.prefers("html") {
            let response = Response(redirect: "/")
            return response
        } else {
            let response = try Response(status: .ok, json: JSON(["message": "OK"]))
            return response
        }
    }
    
}
