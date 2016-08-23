import Vapor
import Fluent
import VaporMySQL
import VaporMustache
import HTTP

let mustache = VaporMustache.Provider(withIncludes: [
    "header" : "Includes/header.mustache",
    "footer" : "Includes/footer.mustache"
])

let preparations: [Preparation.Type] = [Customer.self, Purchase.self]
let providers: [Vapor.Provider.Type] = [VaporMySQL.Provider.self]
let drop = Droplet(preparations: preparations, providers: providers, initializedProviders: [mustache])

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

let purchases = PurchaseController(droplet: drop)
drop.resource("purchases", purchases)

let purchaseMiddleware = PurchaseMiddleware(droplet: drop)
drop.middleware.append(purchaseMiddleware)

let port = drop.config["app", "port"].int ?? 80

drop.serve()
