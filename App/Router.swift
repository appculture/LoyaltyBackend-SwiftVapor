import Vapor
import HTTP

final class Router {
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func configureRoutes() {
        configureHomepage()
        configureCustomers()
        configurePurchases()
        configureVouchers()
        configureUsers()
    }
    
}

// MARK: - Homepage

extension Router {
    
    func configureHomepage() {
        drop.get("/") { request in
            var userID = ""
            let cookieArray = request.cookies.array
            for cookie: Cookie in cookieArray {
                if cookie.name == "user" {
                    userID = cookie.value
                }
            }
            
            guard
                let _ = try UserSession.query().filter("user_id", userID).first()
            else {
                return try self.drop.view("login.mustache")
            }
            
            return Response(redirect: "/customers")
        }
    }
    
}

// MARK: - Customers

extension Router {
    
    func configureCustomers() {
        let customers = CustomerController(droplet: drop)
        drop.resource("customers", customers)
        
        drop.post("customers/login") { request in
            return try customers.login(request: request)
        }
        
        drop.post("customers/logout") { request in
            return try customers.logout(request: request)
        }
        
        drop.post("customers", Customer.self, "purchases") { request, customer in
            return try customers.getPurchases(request: request, customer: customer)
        }
        
        drop.post("customers", Customer.self, "vouchers") { request, customer in
            return try customers.getVouchers(request: request, customer: customer)
        }
        
        let customerMiddleware = CustomerMiddleware(droplet: drop)
        drop.middleware.append(customerMiddleware)
    }
    
}

// MARK: - Purchases

extension Router {
    
    func configurePurchases() {
        let purchases = PurchaseController(droplet: drop)
        drop.resource("purchases", purchases)
        
        let purchaseMiddleware = PurchaseMiddleware(droplet: drop)
        drop.middleware.append(purchaseMiddleware)
    }
    
}

// MARK: - Vouchers

extension Router {
    
    func configureVouchers() {
        let vouchers = VoucherController(droplet: drop)
        drop.resource("vouchers", vouchers)
        
        drop.get("vouchers/config") { request in
            return try vouchers.getConfig(request: request)
        }
        
        drop.post("vouchers/config") { request in
            return try vouchers.editConfig(request: request)
        }
        
        let voucherMiddleware = VoucherMiddleware(droplet: drop)
        drop.middleware.append(voucherMiddleware)
    }
    
}

// MARK: - Users - Admin

extension Router {
    
    func configureUsers() {
        let user = UserController(droplet: drop)
        
        drop.post("login") { request in
            return try user.login(request: request)
        }
        
        drop.post("logout") { request in
            return try user.logout(request: request)
        }
    }
    
}
