public class BaseRequestHandlerArgs: BaseHandlerArgs {
    public var request: NSMutableURLRequest

    required init(_ request: NSMutableURLRequest) {
        self.request = request
        super.init()

        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let method = HttpMethod(rawValue: request.httpMethod)!

        switch method {
        case .patch:
            if let components = request.url?.pathComponents {
                entityName = components[components.count - 2]
            }
            break

        case .post, .delete, .get:
            entityName = request.url?.pathComponents.last
            break
        }

        if let en = entityName {
            entityType = NSClassFromString(String(format: "%@.%@", arguments: [appName, en])) as! BaseEntity.Type
        }
    }
}