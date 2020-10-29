import ballerina/http;
import ballerina/java.jdbc;

jdbc:Client customerDB = check new ("jdbc:mysql://localhost:3306/CustomerDB?serverTimezone=UTC", "root", "Test.1234");

type Customer record {|
    int id;
    string name;
    int age;
|};

@http:ServiceConfig { 
    basePath: "/data" 
}
service customerDS on new http:Listener(8080) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/customers"
    }
    resource function getCustomers(http:Caller caller, http:Request req) returns error? {
        stream<record{}, error> entries = <@untainted> customerDB->query("SELECT * FROM Customer", Customer);
        json result = check from var entry in entries select entry.toJson();
        check caller->respond(result);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/customers/{id}"
    }
    resource function getCustomerById(http:Caller caller, http:Request req, int id) returns error? {
        stream<record{}, error> entries = <@untainted> customerDB->query(
            `SELECT * FROM Customer WHERE id = ${<@untainted> id}`, Customer);
        check caller->respond((check entries.next()).toJson());
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/customers",
        body: "payload"
    }
    resource function addCustomer(http:Caller caller, http:Request req,
                                  Customer payload) returns error? {
        Customer cus = <@untainted> payload;
        _ = check customerDB->execute(`INSERT INTO Customer VALUES (${cus.id}, 
                                 ${cus.name}, ${cus.age})`);
        check caller->ok();
    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/customers",
        body: "payload"
    }
    resource function updateCustomer(http:Caller caller, http:Request req, Customer payload) returns error? {
        Customer cus = <@untainted> payload;
        _ = check customerDB->execute(`UPDATE Customer SET name=${cus.name}, 
                                  age=${cus.age} WHERE id=${cus.id}`);
        check caller->ok();
    }

}