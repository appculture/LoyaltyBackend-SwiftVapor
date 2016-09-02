import Vapor
import Fluent
import VaporMySQL
import VaporMustache
import HTTP

// MARK: - Create Droplet

let mustache = VaporMustache.Provider(withIncludes: [
    "header" : "Includes/header.mustache",
    "footer" : "Includes/footer.mustache"
])

let preparations: [Preparation.Type] = [Customer.self, Purchase.self, Voucher.self, VoucherConfig.self, CustomerSession.self, User.self, UserSession.self, Session.self]
let providers: [Vapor.Provider.Type] = [VaporMySQL.Provider.self]

let drop = Droplet(preparations: preparations, providers: providers, initializedProviders: [mustache])

// MARK: - Configure Routes

let router = Router(droplet: drop)
router.configureRoutes()

// MARK: - Serve Droplet

drop.serve()
