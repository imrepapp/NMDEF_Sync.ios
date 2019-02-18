public class DeviceIdHandler: CustomHandler {
    override open var priority: Int {
        return 10
    }

    required init() {
        super.init([.get, .post, .patch, .delete])
    }

    override open func onBeforeRequest(requestArgs: BaseRequestHandlerArgs) {
        if !(requestArgs.request.allHTTPHeaderFields!["DeviceId"] != nil) {
            requestArgs.request.setValue("1234test123", forHTTPHeaderField: "DeviceId")
        }
    }
}