import EVReflection

public class BaseOperationResponseHandlerArgs: BaseResponseHandlerArgs {
    var entity: BaseEntity?
    var newEntity: BaseEntity?

    required init(request: NSMutableURLRequest, response: URLResponse, data: Data, error: Error?) {
        super.init(request: request, response: response, data: data, error: error)

        if let et = entityType {
            entity = et.init(json: String(data: request.httpBody!, encoding: .utf8))
        }

        if let et = entityType, response.isSuccessStatusCode {
            newEntity = et.init(json: String(data: data, encoding: .utf8))
        }
    }
}