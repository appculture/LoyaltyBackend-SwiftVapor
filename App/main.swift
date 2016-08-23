import Vapor
import Fluent
import VaporMySQL
import VaporMustache
import HTTP

let mustache = VaporMustache.Provider(withIncludes: [
    "header" : "Includes/header.mustache",
    "footer" : "Includes/footer.mustache"
])

var preparations: [Preparation.Type] = [Customer.self, CustomerSession.self]
let providers: [Vapor.Provider.Type] = [VaporMySQL.Provider.self]
let drop = Droplet(preparations: preparations, providers: providers, initializedProviders: [mustache])

drop.get("/") { request in
    return "Hello, Royalty!"
}

let customers = CustomerController(droplet: drop)
drop.resource("customers", customers)

//drop.post("customers", Customer.self, "login") { request, customer in
//    return try customers.login(request: request, item: customer)
//}

drop.post("customers/login") { request in
    return try customers.login(request: request)
}

drop.post("customers/logout") { request in
    return try customers.logout(request: request)
}

let customerMiddleware = CustomerMiddleware(droplet: drop)
drop.middleware.append(customerMiddleware)

let port = drop.config["app", "port"].int ?? 80

drop.serve()
