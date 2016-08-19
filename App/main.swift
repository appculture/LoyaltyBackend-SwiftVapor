import Vapor
import VaporMustache
import HTTP

let drop = Droplet(providers: [VaporMustache.Provider.self])

drop.get("/") { request in
    return "Hello, Royalty!"
}

drop.get("mongo") { request in
    let customerDocuments = try MongoDB.shared.Customer.find()
    let json = customerDocuments.makeDocument().makeExtendedJSON()
    return json
}

drop.get("customers") { request in
    let customerDocuments = try MongoDB.shared.Customer.find()
    let customerList = Array(customerDocuments).map { Customer.init(document: $0) }
    let customerListJSON = customerList.flatMap { try? $0!.makeJSON() }
    return JSON(["Customers" : .array(customerListJSON)])
}

drop.middleware.append(SampleMiddleware())

let port = drop.config["app", "port"].int ?? 80

drop.serve()
