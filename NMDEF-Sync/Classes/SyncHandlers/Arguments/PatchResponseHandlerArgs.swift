class PatchResponseHandlerArgs: BaseOperationResponseHandlerArgs {
    required init(request: NSMutableURLRequest, response: URLResponse, data: Data, error: Error?) {
        super.init(request: request, response: response, data: data, error: error)
    }
}