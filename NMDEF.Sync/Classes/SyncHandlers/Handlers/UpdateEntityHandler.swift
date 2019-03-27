import MicrosoftAzureMobile_Xapt

public class UpdateEntityHandler: PatchHandler {
    override open func onBeforeRequest(requestArgs: BaseRequestHandlerArgs) {
        super.onBeforeRequest(requestArgs: requestArgs)
    }

    override open func onAfterRequest(responseArgs: BaseResponseHandlerArgs) {
        super.onAfterRequest(responseArgs: responseArgs)

        do {
            let args = responseArgs as! PatchResponseHandlerArgs
            try deleteUnsuccessfulOperation(table: args.entityName!, itemId: args.entity!.id)
        } catch {
            print(error)
        }
    }
}