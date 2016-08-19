import Vapor
import HTTP
import Routing

class CustomerCollection: RouteCollection {

    typealias Wrapped = HTTP.Responder

    func build<B: RouteBuilder where B.Value == Wrapped>(_ builder: B) {
        let customers = builder.grouped("customers")

        customers.get("register.json") { request in
            return "register.json"
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
