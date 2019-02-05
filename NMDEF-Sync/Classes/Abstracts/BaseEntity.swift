import EVReflection
import RealmSwift

open class BaseEntity: BaseObject {
    @objc dynamic var id = ""
//    @objc dynamic var updatedAt = Date(timeIntervalSince1970: 1)
//    @objc dynamic var createdAt = Date(timeIntervalSince1970: 1)
    @objc dynamic var version = ""
    @objc dynamic var deleted = false
//    @objc dynamic var dataAreaId = ""

    override open class func primaryKey() -> String? {
        return "id"
    }
}
