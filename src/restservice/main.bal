import ballerina/http;
import ballerina/log;



map<json> customerMap = {};

// RESTful service.
@http:ServiceConfig { basePath: "/customermgt" }
service customerMgt on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/customer/{customerId}"
    }
    resource function findCustomer(http:Caller caller, http:Request req, string customerId) {
        //retrieve it in JSON format.
        json? payload = customerMap[customerId];
        http:Response response = new;
        if (payload == null) {
            payload = "Customer : " + customerId + " cannot be found.";
        }

        //outgoing response message.
        response.setJsonPayload(<@untainted> payload);

        //response to the client.
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }


    @http:ResourceConfig {
        methods: ["POST"],
        path: "/customer"
    }
    resource function addCustomer(http:Caller caller, http:Request req) {
        http:Response response = new;
        json|error customerReq = req.getJsonPayload();
        if (customerReq is json) {
            string customerId = customerReq.Customer.ID.toString();
            customerMap[customerId] = <@untainted> customerReq;

            json payload = { status: "customer Created.", customerId: customerId };
            response.setJsonPayload(payload);

            response.statusCode = 201;
            response.setHeader("Location", "http://localhost:9090/customermgt/customer/" +
                    customerId);


            var result = caller->respond(response);
            if (result is error) {
                log:printError("Error sending response", err = result);
            }
        } else {
            response.statusCode = 400;
            response.setPayload("Invalid payload received");
            var result = caller->respond(response);
            if (result is error) {
                log:printError("Error sending response", err = result);
            }
        }
    }


    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/customer/{customerId}"
    }
    resource function updateCustomer(http:Caller caller, http:Request req, string customerId) {
        json? oldcustomer = customerMap[customerId];
        log:printDebug(oldcustomer);
        var customerReq = req.getJsonPayload();
        http:Response response = new;
        if (customerReq is json) {
            if (oldcustomer != null) {

                oldcustomer=customerReq;
                customerMap[customerId]=<@untainted> oldcustomer;

            } else {
                oldcustomer = "Customer : " + customerId + " cannot be found.";
            }
            response.setJsonPayload(<@untainted> oldcustomer);
            var result = caller->respond(response);
            if (result is error) {
                log:printError("Error sending response", err = result);
            }
        } else {
            response.statusCode = 400;
            response.setPayload("Invalid payload received");
            var result = caller->respond(response);
            if (result is error) {
                log:printError("Error sending response", err = result);
            }
        }
    }

}
