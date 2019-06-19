/** Developer 	:Sachin/Vinit
 * Date : 		02 Feb 2019
 * Purpose:	 	generic class to generate http mock response
 **/
public class HttpMockGenerator implements HttpCalloutMock {
    public Integer code;
    public String status;
    public String bodyAsString;
    public Blob bodyAsBlob;
    public HttpMockGenerator(Integer code, String status, String body) {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
        
    }
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(code);
        response.setStatus(status);
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyAsString);
        system.debug('response from mock: ' + response);
        return response; 
    }
}