class BaseRequestHandlerArgs: BaseHandlerArgs {
    public var request: NSMutableURLRequest

    required init(_ request: NSMutableURLRequest) {
        self.request = request
        super.init()

        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let method = HttpMethod(rawValue: request.httpMethod)!
        entityName = request.url?.pathComponents.last

        if let en = entityName {
            entityType = NSClassFromString(String(format: "%@.%@", arguments: [appName, en])) as! BaseEntity.Type
        }
    }
}