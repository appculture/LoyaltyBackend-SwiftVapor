import Vapor
import Fluent
import VaporMySQL
import VaporMustache
import HTTP

let preparations: [Preparation.Type] = [Customer.self]
let providers: [Vapor.Provider.Type] = [VaporMustache.Provider.self, VaporMySQL.Provider.self]
let drop = Droplet(preparations: preparations, providers: providers)

drop.get("/") { request in
    return "Hello, Royalty!"
}

let customers = CustomerController(droplet: drop)
drop.resource("customers", customers)

drop.post("customers", Customer.self, "login") { request, customer in
    return try customers.login(request: request, item: customer)
}

let customerMiddleware = CustomerMiddleware(droplet: drop)
drop.middleware.append(customerMiddleware)

let port = drop.config["app", "port"].int ?? 80

drop.serve()
