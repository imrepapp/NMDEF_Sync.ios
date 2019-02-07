public class CustomHandler: BaseHandler {
    required init() {
        super.init()
    }

    override init(_ methods: [HttpMethod]) {
        super.init(methods)
    }
}