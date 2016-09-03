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
        configureUsers()
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
            if let _ = request.user {
                return Response(redirect: "/users")
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

// MARK: - Users

extension Router {
    
    func configureUsers() {
        let userController = UserController(droplet: drop)
        drop.resource("users", userController)
        
        drop.post("users", User.self, "purchases") { request, user in
            return try userController.getPurchases(request: request, user: user)
        }
        
        drop.post("users", User.self, "vouchers") { request, user in
            return try userController.getVouchers(request: request, user: user)
        }
        
        let userMiddleware = UserMiddleware(droplet: drop)
        drop.middleware.append(userMiddleware)
    }
    
}

// MARK: - Purchases

extension Router {
    
    func configurePurchases() {
        let purchaseController = PurchaseController(droplet: drop)
        drop.resource("purchases", purchaseController)
        
        let purchaseMiddleware = PurchaseMiddleware(droplet: drop)
        drop.middleware.append(purchaseMiddleware)
    }
    
}

// MARK: - Vouchers

extension Router {
    
    func configureVouchers() {
        let voucherController = VoucherController(droplet: drop)
        drop.resource("vouchers", voucherController)
        
        drop.get("vouchers/config") { request in
            return try voucherController.getConfig(request: request)
        }
        
        drop.post("vouchers/config") { request in
            return try voucherController.editConfig(request: request)
        }
        
        let voucherMiddleware = VoucherMiddleware(droplet: drop)
        drop.middleware.append(voucherMiddleware)
    }
    
}
