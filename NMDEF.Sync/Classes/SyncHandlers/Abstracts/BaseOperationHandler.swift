import MicrosoftAzureMobile_Xapt
import RealmSwift

open class BaseOperationHandler: BaseHandler {
    public required init() {
        super.init()
    }

    public override init(_ method: HttpMethod) {
        super.init(method)
    }

    public override init(_ methods: [HttpMethod]) {
        super.init(methods)
    }

    public func deleteUnsuccessfulOperation(table: String, itemId: String) throws {
        let realm = try! Realm()
        let row = realm.objects(MS_TableOperations.self).filter(NSPredicate(format: "itemId = %@ and table = %@", argumentArray: [
            itemId,
            table
        ]))

        try! realm.write {
            realm.delete(row)
        }
    }
}