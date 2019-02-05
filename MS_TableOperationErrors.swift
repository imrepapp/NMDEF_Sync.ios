import RealmSwift

class MS_TableOperationErrors: BaseEntity {
    @objc dynamic var operationId: Int64 = 0
    @objc dynamic var properties: NSData?
    @objc dynamic var tableKind: Int16 = 0

    override class func ignoredProperties() -> [String] {
        return ["dataAreaId", "updatedAt", "createdAt", "version", "deleted"]
    }
}
