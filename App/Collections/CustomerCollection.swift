import Vapor
import HTTP
import Routing

class CustomerCollection: RouteCollection {

    typealias Wrapped = HTTP.Responder

    func build<B: RouteBuilder where B.Value == Wrapped>(_ builder: B) {
        let customers = builder.grouped("customers")

        customers.post("register.json") { request in
            if
                let contentType = request.headers["Content-Type"],
                contentType == "application/json",
                
                let bytes = request.body.bytes,
                let json = try? JSON(bytes: bytes),
                
                let first = json.object?["first"].string,
                let last = json.object?["last"].string,
                let email = json.object?["email"].string,
                let password = json.object?["password"].string
            {
                return "Body:\n first: \(first)\n last: \(last)\n email: \(email)\n password: \(password)"
            } else {
                throw Abort.badRequest
            }
        }

        customers.get("login.json") { request in
            return "login.json"
        }

        customers.get("show.json") { request in
            return "show.json"
        }

		customers.get("list.json") { request in
        	return "list.json"
        }
    }

}
