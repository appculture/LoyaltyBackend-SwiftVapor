import Vapor
import VaporMustache
import HTTP
import VaporMySQL

//let drop = Droplet(preparations: [User.self], providers: [VaporMustache.Provider.self, MongoProvider.self])
let drop = Droplet(preparations: [User.self], providers: [VaporMustache.Provider.self, VaporMySQL.Provider.self])

drop.get("/") { request in
    return "Hello, Royalty!"
}

drop.get("mongo") { request in
    let customerDocuments = try MongoDB.shared.Customer.find()
    let json = customerDocuments.makeDocument().makeExtendedJSON()
    return json
}

drop.get("mongo-customers") { request in
    let customerDocuments = try MongoDB.shared.Customer.find()
    let customerList = Array(customerDocuments).map { Customer.init(document: $0) }
    let customerListJSON = customerList.flatMap { try? $0!.makeJSON() }
    return JSON(["Customers" : .array(customerListJSON)])
}

//let customerCollection = CustomerCollection()
//drop.collection(customerCollection)

/*
drop.post("customers") { request in
    guard
        let first = request.data["first"].string,
        let last = request.data["last"].string,
        let email = request.data["email"].string,
        let password = request.data["password"].string
    else {
        throw Abort.badRequest
    }
    
    return try JSON([
        "first": first,
        "last": last,
        "email": email,
        "password": password,
    ])
}
*/

let customers = CustomerController(droplet: drop)
drop.resource("customers", customers)


drop.post("users") { request in
    guard
        let name = request.data["name"].string
    else {
        throw Abort.badRequest
    }
    
    var user = User(name: name)
    
    do {
        try user.save()
    } catch {
        print(error)
    }
    
    return user
}


drop.middleware.append(SampleMiddleware())

let port = drop.config["app", "port"].int ?? 80

drop.serve()
