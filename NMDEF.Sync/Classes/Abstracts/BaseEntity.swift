import EVReflection
import RealmSwift

open class BaseEntity: BaseObject {
    @objc public dynamic var id = ""
    @objc public dynamic var version = ""
    @objc public dynamic var deleted = false

    override open class func primaryKey() -> String? {
        return "id"
    }
}
