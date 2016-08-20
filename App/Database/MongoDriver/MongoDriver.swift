import Fluent
import MongoKitten

public class MongoDriver: Fluent.Driver {
    public var idKey: String = "_id"
    
    public var server: MongoKitten.Server
    public var database: MongoKitten.Database
    
    public enum DriverError: Error {
        case notSupported(String)
    }

    /**
        Attempts to establish a connection to a MySQL database
        engine running on host.

        - parameter host: May be either a host name or an IP address.
        If host is the string "localhost", a connection to the local host is assumed.
        - parameter user: The user's MySQL login ID.
        - parameter password: Password for user.
        - parameter database: Database name.
        The connection sets the default database to this value.
        - parameter port: If port is not 0, the value is used as
        the port number for the TCP/IP connection.
        - parameter socket: If socket is not NULL,
        the string specifies the socket or named pipe to use.
        - parameter flag: Usually 0, but can be set to a combination of the
        flags at http://dev.mysql.com/doc/refman/5.7/en/mysql-real-connect.html


        - throws: `Error.connection(String)` if the call to
        `mysql_real_connect()` fails.
    */
    public init(
        host: String,
        user: String,
        password: String,
        database: String,
        port: UInt = 3306
    ) throws {
        server = try Server("mongodb://\(user):\(password)@\(host):\(port)", automatically: true)
        self.database = server[database]
    }

    /**
        Creates the driver from an already
        initialized database.
    */
    public init(_ database: MongoKitten.Database) {
        self.server = database.server
        self.database = database
    }

    /**
        Queries the database.
    */
    @discardableResult
    public func query<T: Entity>(_ query: Fluent.Query<T>) throws -> Node {
        /*
        let serializer = MySQLSerializer(sql: query.sql)
        let (statement, values) = serializer.serialize()

        // create a reusable connection 
        // so that LAST_INSERT_ID can be fetched
        let connection = try database.makeConnection()

        let results = try mysql(statement, values, connection)

        if query.action == .create {
            let insert = try mysql("SELECT LAST_INSERT_ID() as id", [], connection)
            if
                case .array(let array) = insert,
                let first = array.first,
                case .object(let obj) = first,
                let id = obj["id"]
            {
                return id
            }
        }

        return results
        */
        
        //throw DriverError.notSupported("Query not supported.")
        return Node(10.0)
    }

    /**
        Creates the desired schema.
    */
    public func schema(_ schema: Schema) throws {
        throw DriverError.notSupported("Schema not supported.")
    }

    /**
        Conformance to the RawQueryable protocol
        allowing plain query strings and value arrays
        to be attempted.
    */
    @discardableResult
    public func raw(_ query: String, _ values: [Node] = []) throws -> Node {
        throw DriverError.notSupported("Raw query is not currently supported.")
    }

    /**
        Provides access to the underlying MySQL database
        for running raw queries.
    */
    /*
    @discardableResult
    public func mysql(_ query: String, _ values: [Node] = [], _ connection: MySQL.Connection? = nil) throws -> Node {
        let results = try database.execute(query, values.map({ $0 as NodeRepresentable }), connection).map { Node.object($0) }
        return .array(results)
    }
    */
}

