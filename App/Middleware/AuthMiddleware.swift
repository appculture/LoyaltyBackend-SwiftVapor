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
        do {
            try validateRequest(request)
            let response = try chain.respond(to: request)
            return response
        } catch {
            if request.accept.prefers("html") {
                let response = Response(redirect: "/login")
                return response
            } else {
                throw error
            }
        }
    }
    
    func validateRequest(_ request: Request) throws {
        if !shouldSkipTokenValidation(forRequest: request) {
            do {
                try validateToken(fromRequest: request)
            } catch {
                guard request.uri.path == "/login" else { throw error }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func shouldSkipTokenValidation(forRequest request: Request) -> Bool {
        let path = request.uri.path
        
        if path.contains(".css") || path.contains(".js") {
            return true
        }
        
        switch request.method {
        case .get:
            let allowed = ["/"]
            return allowed.contains(path)
        case .post:
            let allowed = ["/users", "/login"]
            return allowed.contains(path)
        default:
            return false
        }
    }
    
    private func validateToken(fromRequest request: Request) throws {
        let error = Abort.custom(status: .unauthorized, message: "Permission denied.")
        guard let token = request.token else { throw error }
        guard SessionController.validateSession(withToken: token) else { throw error }
        request.authorized = true
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
    
    var authorized: Bool {
        get { return storage["authorized"] as? Bool ?? false }
        set { storage["authorized"] = newValue }
    }
    
}
