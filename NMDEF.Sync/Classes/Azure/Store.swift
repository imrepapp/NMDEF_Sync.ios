import UIKit
import RealmSwift
import EVReflection
import MicrosoftAzureMobile_Xapt

public class Store: NSObject, MSSyncContextDataSource {
    func systemProperties(forTable table: String) -> UInt {
        return 0
    }

    public var handlesSyncTableOperations: Bool = false

    override init() {
        super.init()
        handlesSyncTableOperations = true
    }

    public func operationTableName() -> String {
        return "MS_TableOperations"
    }

    public func errorTableName() -> String {
        return "MS_TableOperationErrors"
    }

    public func configTableName() -> String {
        return "MS_TableConfig"
    }

    public func read(with query: MSQuery?) throws -> MSSyncContextReadResult {
        let tableObj: Object.Type = getTableObj(tableName: (query!.syncTable?.name)!)
        var totalCount: Int = -1
        var results: Array<Dictionary<AnyHashable, Any>> = Array()

        let realm = try! Realm()
        var rawResults = realm.objects(tableObj)

        // Only calculate total count if fetchLimit/Offset is set
        if query!.includeTotalCount && (query!.fetchLimit != -1 || query!.fetchOffset != -1) {
            totalCount = realm.objects(tableObj).count

            // If they just want a count quit out
            if (query!.fetchLimit == 0) {
                return MSSyncContextReadResult(count: totalCount, items: results);
            }
        }

        let predicate = query?.predicate
        if predicate != nil {
            rawResults = rawResults.filter(predicate!)
        }

        if let orderBy = query?.orderBy {
            var sorts: [SortDescriptor] = []
            for order in orderBy {
                if let key = order.key {
                    sorts.append(SortDescriptor.init(keyPath: key, ascending: order.ascending))
                }
            }
            rawResults = rawResults.sorted(by: sorts)
        }

        var offset = 0
        if let o = query?.fetchOffset {
            offset = o
        }

        var limit = 1
        if let l = query?.fetchLimit {
            limit = l
        }

        if offset == -1 && limit == -1 {
            for r in rawResults {
                results.append((r as! BaseObject).toDict())
            }
        } else {
            for r in rawResults.get(offset: offset, limit: limit) {
                results.append((r as! BaseObject).toDict())
            }
        }

        if query!.includeTotalCount && totalCount != -1 {
            totalCount = results.count
        }

        return MSSyncContextReadResult(count: totalCount, items: results)
    }

    public func readTable(_ table: String, withItemId itemId: String, orError error: NSErrorPointer) -> [AnyHashable: Any]? {
        do {
            if let r = try (getRecordForTable(table: table, itemId: itemId) as? BaseEntity)?.toDict() {
                return r
            }
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    public func upsertItems(_ items: [[AnyHashable: Any]]?, table: String) throws {
        let tableObj = getTableObj(tableName: table)
        
        if let realItems = items, let maxCount = items?.count {
            for index in 0..<maxCount {
                var item = realItems[index]

                do {
                    let dict = item as NSDictionary? as! [String: Any]?
                    var existsItem: Object?

                    let realm = try! Realm()

                    if let to = existsItem as? BaseEntity {
                        existsItem = try getRecordForTable(table: table, itemId: dict![MSSystemColumnId] as! String)
                    } else  {
                        existsItem = realm.objects(tableObj).filter(NSPredicate(format: "id = %d", argumentArray: [item[MSSystemColumnId]])).first
                    }

                    try! realm.write {
                        if (existsItem == nil) {
                            let to = (tableObj as! BaseObject.Type).init(dictionary: item as NSDictionary)
                            realm.add(to)
                        } else {
                            realm.add(try (existsItem as! BaseObject).toModel(data: item as NSDictionary), update: true)
                        }
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    public func deleteItems(withIds items: [String], table: String) throws {
        let realm = try! Realm()
        let tableObj = getTableObj(tableName: table)

        var deletableItems: Results<Object>

        if tableObj is BaseEntity.Type {
            deletableItems = realm.objects(tableObj).filter("id IN %@", items)
        } else {
            deletableItems = realm.objects(tableObj).filter("id IN %d", items.map { Int($0) })
        }

        try! realm.write {
            realm.delete(deletableItems)
        }
    }

    public func delete(using query: MSQuery) throws {
        let items = try read(with: query).items

        if items.count > 0 {
            try deleteItems(withIds: items.map{ $0[MSSystemColumnId] as! String }, table: query.syncTable?.name ?? "")
        }
    }

    private func getTableObj(tableName: String) -> Object.Type {
        switch tableName {
            case configTableName():
                return MS_TableConfig.self as! Object.Type
            case errorTableName():
                return MS_TableOperationErrors.self as! Object.Type
            case operationTableName():
                return MS_TableOperations.self as! Object.Type
            default:
                return NSClassFromString(String(format: "%@.%@", arguments: [Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String, tableName]))!
                        as! Object.Type
        }
    }

    public func getRecordForTable(table: String, itemId: String) throws -> Object? {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id == %@", argumentArray: [itemId])
        let tableObj = getTableObj(tableName: table)
        var v = realm.objects(tableObj).filter(predicate).first
        return realm.objects(tableObj).filter(predicate).first
    }
}
