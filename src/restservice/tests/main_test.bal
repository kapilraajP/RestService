import ballerina/test;
import ballerina/http;

http:Client clientEP = new("http://localhost:9090/customermgt");

@test:Config{}
function testResourceAddCustomer() {

    http:Request req = new;

    json payload = { "Customer": { "ID": "100500", "Name": "XYZ", "Description": "Sample customer." } };
    req.setJsonPayload(payload);

    var response = clientEP->post("/customer", req);
    if (response is http:Response) {

        test:assertEquals(response.statusCode, 201,
            msg = "addCustomer resource did not respond with expected response code!");

        var resPayload = response.getJsonPayload();
        if (resPayload is json) {
            test:assertEquals(resPayload.toString(),
                "{\"status\":\"customer Created.\",\"customerId\":\"100500\"}", msg = "Response mismatch!");
        } else {
            test:assertFail(msg = "Failed to retrieve the payload");
        }
    } else {
        test:assertFail(msg = "Error sending request");
    }
}

@test:Config {
    dependsOn: ["testResourceAddCustomer"]
}

function testResourceUpdateCustomer() {

    http:Request req = new;

    json payload = { "Customer": { "Name": "XYZ", "Description": "Updated customer." } };
    req.setJsonPayload(payload);

    var response = clientEP->put("/customer/100500", req);
    if (response is http:Response) {

        test:assertEquals(response.statusCode, 200,
            msg = "updateCustomer resource did not respond with expected response code!");

        var resPayload = response.getJsonPayload();
        if (resPayload is json) {
            test:assertEquals(resPayload.toString(),
                "{\"Customer\":{\"Name\":\"XYZ\",\"Description\":\"Updated customer.\"}}",
                msg = "Response mismatch!");
        } else {
            test:assertFail(msg = "Failed to retrieve the payload");
        }
    } else {
        test:assertFail(msg = "Error sending request");
    }
}

@test:Config {
    dependsOn: ["testResourceUpdateCustomer"]
}

function testResourceFindCustomer() {

    var response = clientEP->get("/customer/100500");
    if (response is http:Response) {

        test:assertEquals(response.statusCode, 200,
            msg = "findCustomerresource did not respond with expected response code!");

        var resPayload = response.getJsonPayload();
        if (resPayload is json) {
            test:assertEquals(resPayload.toString(),
                "{\"Customer\":{\"Name\":\"XYZ\",\"Description\":\"Updated customer.\"}}",
                msg = "Response mismatch!");
        } else {
            test:assertFail(msg = "Failed to retrieve the payload");
        }
    } else {
        test:assertFail(msg = "Error sending request");
    }
}

