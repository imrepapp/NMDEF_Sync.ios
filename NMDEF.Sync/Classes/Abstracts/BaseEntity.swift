import EVReflection
import RealmSwift
import NMDEF_Base

open class BaseEntity: BaseObject, BaseModel {
    @objc public dynamic var id = ""
    @objc public dynamic var version = ""
    @objc public dynamic var deleted = false

    override open class func primaryKey() -> String? {
        return "id"
    }
}
