import Foundation
import Vapor

final class SessionController {
    
    static func establishSession(forUser user: User) throws -> Session {
        guard let userID = user.id else { throw Abort.serverError }
        
        if let existing = try existingSession(withUserID: userID) {
            return existing
        } else {
            return try newSession(withUserID: userID)
        }
    }
    
    static func existingSession(withUserID userID: Node) throws -> Session? {
        return try Session.query().filter("user_id", userID).first()
    }
    
    static func newSession(withUserID userID: Node) throws -> Session {
        #if os(Linux)
            let randomUUID = NSUUID().UUIDString
        #else
            let randomUUID = NSUUID().uuidString
        #endif
        
        var session = Session(userID: userID, token: randomUUID)
        try session.save()
        
        return session
    }
    
    static func validateSession(withToken token: String) throws -> Session? {
        let session = try Session.query().filter("token", token).first()
        return session
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
