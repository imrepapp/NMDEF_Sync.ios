import MicrosoftAzureMobile

class ClientFilter: NSObject, MSFilter {
    static var handlers: [BaseHandler] = []

    private var currentHandlers: [BaseHandler] = []

    func handle(_ request: URLRequest, next: @escaping MSFilterNextBlock, response: @escaping MSFilterResponseBlock) {
        let mutableRequets: NSMutableURLRequest = ((request as NSURLRequest).mutableCopy() as? NSMutableURLRequest)!

        if !(mutableRequets.allHTTPHeaderFields!["DeviceId"] != nil) {
            mutableRequets.setValue("1234test123", forHTTPHeaderField: "DeviceId")
        }

        onBeforeRequest(mutableRequets)

        next((mutableRequets as URLRequest), {
            (res, data, error) in
            self.onAfterRequest(request: mutableRequets, response: res!, data: data!, error: error)
            response(res, data, error)
        })
    }

    private func onBeforeRequest(_ request: NSMutableURLRequest) {
        let method = HttpMethod(rawValue: request.httpMethod)!
        var requestArgs: BaseRequestHandlerArgs?

        switch method {
            case .get:
                requestArgs = GetRequestHandlerArgs(request)
            case .post:
                requestArgs = PostRequestHandlerArgs(request)
            case .patch:
                requestArgs = PatchRequestHandlerArgs(request)
            case .delete:
                requestArgs = DeleteRequestHandlerArgs(request)
        }

        currentHandlers = ClientFilter.handlers
                .filter { $0.methods.contains(method) && ($0.types.count == 0 || $0.types.contains(requestArgs?.entityName as! String)) }
                .sorted(by: { $0.priority < $1.priority })

        if let ra = requestArgs {
            for h in currentHandlers {
                h.onBeforeRequest(requestArgs: ra)
            }
        }
    }

    private func onAfterRequest(request: NSMutableURLRequest, response: URLResponse, data: Data, error: Error?) {
        let method = HttpMethod(rawValue: request.httpMethod)!
        var responseArgs: BaseResponseHandlerArgs?

        switch method {
            case .get:
                responseArgs = GetResponseHandlerArgs(request: request, response: response, data: data, error: error)
            case .post:
                responseArgs = PostResponseHandlerArgs(request: request, response: response, data: data, error: error)
            case .patch:
                responseArgs = PatchResponseHandlerArgs(request: request, response: response, data: data, error: error)
            case .delete:
                responseArgs = DeleteResponseHandlerArgs(request: request, response: response, data: data, error: error)
        }

        if let ra = responseArgs {
            for h in currentHandlers {
                h.onAfterRequest(responseArgs: ra)
            }
        }
    }
}
