import Foundation
import Vapor

final class SessionController {
    
    static func createSession(forUser user: User) throws -> Session {
        guard let userID = user.id else { throw Abort.serverError }
        
        #if os(Linux)
            let randomUUID = NSUUID().UUIDString
        #else
            let randomUUID = NSUUID().uuidString
        #endif
        
        var session = Session(userID: userID, token: randomUUID)
        try session.save()
        
        return session
    }
    
    static func validateSession(withToken token: String) -> Bool {
        do {
            guard let _ = try Session.query().filter("token", token).first() else { return false }
            return true
        } catch {
            return false
        }
    }
    
    static func destroySession(withToken token: String) throws {
        do {
            let session = try Session.query().filter("token", token).first()
            try session?.delete()
        } catch {
            throw Abort.notFound
        }
    }
    
}
