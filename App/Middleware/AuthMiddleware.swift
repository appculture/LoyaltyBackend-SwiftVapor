import Vapor
import HTTP

class AuthMiddleware: Middleware {
    
    // MARK: - Properties
    
    let drop: Droplet
    
    // MARK: - Init
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    // MARK: - Override
    
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        if validatePermissionsForRequest(request) {
            return try chain.respond(to: request)
        } else {
            if request.accept.prefers("html") {
                let response = Response(redirect: "/login")
                return response
            } else {
                throw Abort.custom(status: .unauthorized, message: "Permission denied.")
            }
        }
    }
    
    // MARK: - Helpers
    
    func validatePermissionsForRequest(_ request: Request) -> Bool {
        
        if isPublic(request: request) {
            return true
        }
        
        configureUser(forRequest: request)
        guard let user = request.user else { return false }
        
        let allowed = isRequestAllowed(forUser: user, request: request)
        return allowed
    }
    
    func isPublic(request: Request) -> Bool {
        let path = request.uri.path
        
        switch request.method {
        case .get:
            if path.contains(".css") || path.contains(".js") {
                return true
            }
            let allowed = ["/", "/login"]
            return allowed.contains(path)
        case .post:
            let allowed = ["/users", "/login"]
            return allowed.contains(path)
        default:
            return false
        }
    }
    
    func configureUser(forRequest request: Request) {
        guard let token = request.token else { return }
        guard let session = try? SessionController.validateSession(withToken: token) else { return }
        guard let user = try? session?.user().get() else { return }
        request.user = user
    }
    
    func isRequestAllowed(forUser user: User, request: Request) -> Bool {
        guard let role = user.role else { return false }
        
        switch role {
        case .Customer:
            return isRequestAllowed(forCustomer: user, request: request)
        case .Admin:
            return isRequestAllowed(forAdmin: user, request: request)
        }
    }
    
    func isRequestAllowed(forCustomer user: User, request: Request) -> Bool {
        let path = request.uri.path
        guard let userID = user.id?.int else { return false }
        
        if path.contains("users/\(userID)") {
            return true
        }
        
        if request.method == .post {
            let allowed = ["/users", "/login", "/logout"]
            return allowed.contains(path)
        }
        
        return false
    }
    
    func isRequestAllowed(forAdmin: User, request: Request) -> Bool {
        return true
    }
    
}

extension Request {
    
    var token: String? {
        /// - NOTE: Vapor.Session is not working properly in this version (0.16.2). Leave that for later...
        
        let headerToken = data["token"]?.string
        let cookieToken = cookies.array.filter({ $0.name.trim() == "token"}).first?.value
        let token = headerToken ?? cookieToken
        
        return token
    }
    
    var user: User? {
        get { return storage["user"] as? User }
        set { storage["user"] = newValue }
    }
    
}
