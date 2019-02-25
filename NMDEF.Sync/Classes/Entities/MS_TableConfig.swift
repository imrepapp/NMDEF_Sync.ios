import RealmSwift

class MS_TableConfig: BaseEntity {
    @objc dynamic var key = ""
    @objc dynamic var keyType: Int64 = 0
    @objc dynamic var table = ""
    @objc dynamic var value = ""

    override class func ignoredProperties() -> [String] {
        return ["dataAreaId", "updatedAt", "createdAt", "version", "deleted"]
    }
}
