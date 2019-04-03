public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

open class BaseHandler {
    open var priority: Int { return 1000 }
    public var types: [String] { return [] }
    public var methods: [HttpMethod]

    public required init() {
        methods = []
    }

    public init(_ method: HttpMethod) {
        self.methods = [method]
    }

    public init(_ methods: [HttpMethod]) {
        self.methods = methods
    }

    open func onBeforeRequest(requestArgs: BaseRequestHandlerArgs) {

    }

    open func onAfterRequest(responseArgs: BaseResponseHandlerArgs) {
        if !responseArgs.response.isSuccessStatusCode {
            print(String(data: responseArgs.data, encoding: .utf8) ?? "")
        }
    }
}