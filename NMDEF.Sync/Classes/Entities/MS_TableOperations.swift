import RealmSwift

class MS_TableOperations: BaseObject {
//    override dynamic var id: String {
//        get {
//            return super.id
//
//        }
//        set(newValue) {
//            super.id = String(newValue)
//        }
//    }
    @objc dynamic var id = 0
    @objc dynamic var itemId = ""
    @objc dynamic var properties: NSData?
    @objc dynamic var table = ""
    @objc dynamic var tableKind = 0

//    override class func ignoredProperties() -> [String] {
//        return ["dataAreaId", "updatedAt", "createdAt", "version", "deleted"]
//    }
}