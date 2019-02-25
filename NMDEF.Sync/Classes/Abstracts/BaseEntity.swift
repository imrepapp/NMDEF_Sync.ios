import EVReflection
import RealmSwift

open class BaseEntity: BaseObject {
    @objc public dynamic var id = ""
//    @objc public dynamic var updatedAt = Date(timeIntervalSince1970: 1)
//    @objc public dynamic var createdAt = Date(timeIntervalSince1970: 1)
    @objc public dynamic var version = ""
    @objc public dynamic var deleted = false
//    @objc dynamic var dataAreaId = ""

    override open class func primaryKey() -> String? {
        return "id"
    }
}
