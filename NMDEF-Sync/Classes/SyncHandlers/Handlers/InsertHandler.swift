class InsertHandler: PostHandler {
    override func onBeforeRequest(requestArgs: BaseRequestHandlerArgs) {
        super.onBeforeRequest(requestArgs: requestArgs)
    }

    override func onAfterRequest(responseArgs: BaseResponseHandlerArgs) {
        super.onAfterRequest(responseArgs: responseArgs)

        do {
            let args = responseArgs as! PostResponseHandlerArgs
            try BaseDataProvider.instance.store?.deleteItems(withIds: [args.entity!.id], table: args.entityName!)
        } catch {
            // ignore
        }
    }
}