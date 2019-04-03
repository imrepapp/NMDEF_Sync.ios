import EVReflection

public class BaseOperationRequestHandlerArgs: BaseRequestHandlerArgs {
    var entity: BaseEntity?

    required init(_ request: NSMutableURLRequest) {
        super.init(request)

        if let et = entityType {
            entity = et.init(json: String(data: request.httpBody!, encoding: .utf8))
        }
    }
}