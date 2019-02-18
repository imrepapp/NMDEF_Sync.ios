open class CustomHandler: BaseHandler {
    public required init() {
        super.init()
    }

    public override init(_ methods: [HttpMethod]) {
        super.init(methods)
    }
}