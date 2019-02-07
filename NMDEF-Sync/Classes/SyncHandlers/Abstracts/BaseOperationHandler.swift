public class BaseOperationHandler: BaseHandler {
    required init() {
        super.init()
    }

    override init(_ method: HttpMethod) {
        super.init(method)
    }

    override init(_ methods: [HttpMethod]) {
        super.init(methods)
    }
}