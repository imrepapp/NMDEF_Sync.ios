enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

class BaseHandler {
    public var priority: Int { return 1000 }
    public var types: [String] { return [] }
    public var methods: [HttpMethod]

    required init() {
        methods = []
    }

    init(_ method: HttpMethod) {
        self.methods = [method]
    }

    init(_ methods: [HttpMethod]) {
        self.methods = methods
    }

    public func onBeforeRequest(requestArgs: BaseRequestHandlerArgs) {

    }

    public func onAfterRequest(responseArgs: BaseResponseHandlerArgs) {
        if !responseArgs.response.isSuccessStatusCode {
            print(String(data: responseArgs.data, encoding: .utf8))
        }
    }
}