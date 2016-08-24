import Vapor
import HTTP

final class Router {
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func configureRoutes() {
        
        drop.get("/") { request in
            print(request.cookies.array)
            var userID: String = ""
            let cookieArray: Array = request.cookies.array
            for cookie: Cookie in cookieArray {
                if cookie.name == "user" {
                    userID = cookie.value
                }
            }
            guard
                let previousSession: UserSession = try UserSession.query().filter("user_id", userID).first()
                else {
                    return try self.drop.view("index.html")
            }
            print(previousSession)
            return Response(redirect: "/customers")
        }
        
        configureCustomersRoutes()
        configurePurchasesRoutes()
        configureVouchersRoutes()
        configureUserRoutes()
    }
    
}

// MARK: - Customers

extension Router {
    
    func configureCustomersRoutes() {
        let customers = CustomerController(droplet: drop)
        drop.resource("customers", customers)
        
        drop.post("customers/login") { request in
            return try customers.login(request: request)
        }
        
        drop.post("customers/logout") { request in
            return try customers.logout(request: request)
        }
        
        drop.post("customers", Customer.self, "purchases") { request, customer in
            return try customer.purchases().all().makeResponse()
        }
        
        drop.post("customers", Customer.self, "vouchers") { request, customer in
            return try customer.vouchers().all().makeResponse()
        }
        
        let customerMiddleware = CustomerMiddleware(droplet: drop)
        drop.middleware.append(customerMiddleware)
    }
    
}

// MARK: - Purchases

extension Router {
    
    func configurePurchasesRoutes() {
        let purchases = PurchaseController(droplet: drop)
        drop.resource("purchases", purchases)
        
        let purchaseMiddleware = PurchaseMiddleware(droplet: drop)
        drop.middleware.append(purchaseMiddleware)
    }
    
}

// MARK: - Vouchers

extension Router {
    
    func configureVouchersRoutes() {
        let vouchers = VoucherController(droplet: drop)
        drop.resource("vouchers", vouchers)
        
        drop.get("vouchers/config") { request in
            return try vouchers.getConfig(request: request)
        }
        
        drop.put("vouchers/config") { request in
            return try vouchers.editConfig(request: request)
        }
        
        let voucherMiddleware = VoucherMiddleware(droplet: drop)
        drop.middleware.append(voucherMiddleware)
    }
    
}

// MARK: - Users - Admin

extension Router {
    func configureUserRoutes() {
        let user = UserLoginController(droplet: drop)
        drop.resource("user", user)
        
        drop.post("login") { request in
            return try user.login(request: request)
        }
    }
    
}
