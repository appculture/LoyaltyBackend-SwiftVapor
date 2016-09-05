import Vapor
import HTTP

class ErrorMiddleware: Middleware {
    
    // MARK: - Properties
    
    let drop: Droplet
    
    // MARK: - Init
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    // MARK: - Override
    
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        do {
            return try chain.respond(to: request)
        } catch {
            let view = request.accept.prefers("html")
            let response: Response
            
            switch error {
            case Abort.badRequest:
                response = try self.errorResponse(.badRequest, message: "Invalid request", view: view)
            case Abort.notFound:
                response = try self.errorResponse(.notFound, message: "Page not found", view: view)
            case Abort.serverError:
                response = try self.errorResponse(.internalServerError, message: "Something went wrong", view: view)
            case Abort.custom(let status, let message):
                response = try self.errorResponse(status, message: message, view: view)
            default:
                response = try self.errorResponse(.internalServerError, message: error.localizedDescription, view: view)
            }
            
            return response
        }
    }
    
    // MARK: - Helpers
    
    func errorResponse(_ status: Status, message: String, view: Bool) throws -> Response {
        let json = try JSON(node: [
            "error": true,
            "message": "\(message)"
        ])
        let data = try json.makeBytes()
        
        if view {
            return try drop.view("error.mustache", context: [
                "message": message
            ]).makeResponse()
        } else {
            let response = Response(status: status, body: .data(data))
            response.headers["Content-Type"] = "application/json; charset=utf-8"
            return response
        }
    }
    
}
