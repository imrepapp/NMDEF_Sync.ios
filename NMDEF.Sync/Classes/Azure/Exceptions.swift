enum TableOperationException: Error {
    case UpdateFailed
    case InsertFailed
    case DeleteFailed
}

enum TableQueryException: Error {
    case RecordNotFound(itemId: String)
}