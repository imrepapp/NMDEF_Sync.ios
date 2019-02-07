import Foundation

public class BaseResponseHandlerArgs: BaseHandlerArgs {
    public var request: NSMutableURLRequest
    public var response: URLResponse
    public var data: Data
    public var error: Error?

    required init(request: NSMutableURLRequest, response: URLResponse, data: Data, error: Error?) {
        self.request = request
        self.response = response
        self.data = data
        self.error = error

        super.init()

        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let method = HttpMethod(rawValue: request.httpMethod)!
        entityName = request.url?.pathComponents.last

        if let en = entityName {
            entityType = NSClassFromString(String(format: "%@.%@", arguments: [appName, en])) as! BaseEntity.Type
        }
    }
}