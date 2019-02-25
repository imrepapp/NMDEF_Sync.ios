open class BaseOperationHandler: BaseHandler {
    public required init() {
        super.init()
    }

    public override init(_ method: HttpMethod) {
        super.init(method)
    }

    public override init(_ methods: [HttpMethod]) {
        super.init(methods)
    }
}