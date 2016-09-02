import Vapor
import HTTP

final class Router {
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func configureRoutes() {
        configureHomepage()
        configureLogin()
        configureCustomers()
        configurePurchases()
        configureVouchers()
    }
    
}

// MARK: - Homepage

extension Router {
    
    func configureHomepage() {
        drop.get("/") { request in
            return try self.drop.view("home.mustache")
        }
    }
    
}

// MARK: - Login

extension Router {
    
    func configureLogin() {
        let authMiddleware = AuthMiddleware(droplet: drop)
        drop.middleware.append(authMiddleware)
        
        drop.get("/login") { request in
            if request.authorized {
                return Response(redirect: "/customers")
            } else {
                return try self.drop.view("login.mustache")
            }
        }
        
        let loginController = LoginController(droplet: drop)
        
        drop.post("login") { request in
            return try loginController.login(request: request)
        }
        
        drop.post("logout") { request in
            return try loginController.logout(request: request)
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
