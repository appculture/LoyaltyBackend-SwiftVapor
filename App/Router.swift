import Vapor
import HTTP

final class Router {
    
    let drop: Droplet
    
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func configureRoutes() {
        
        drop.get("/") { request in
            return "Hello, Royalty!"
        }
        
        configureCustomersRoutes()
        configurePurchasesRoutes()
        configureVouchersRoutes()
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
