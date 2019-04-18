import RealmSwift
import RxSwift
import EVReflection
import MicrosoftAzureMobile_Xapt
import NMDEF_Base

public extension BaseSyncDataAccessObject {
    // General
    func syncTable() -> Observable<Void> {
        return self.syncTable(query: self.datasource.query())
    }

    func syncTable(query: MSQuery, label: String? = nil) -> Observable<Void> {
        return BaseDataProvider.instance.syncTable(table: self.datasource, query: query, label: label)
    }

    func update<T: BaseEntity>(model: T) -> Observable<Bool> {
        return Observable.create { observer in
            self.datasource.update(model.toDict(), completion: { (error) -> Void in

                guard error == nil else {
                    observer.onError(error!)
                    return
                }

                observer.onNext(true)
                observer.onCompleted()
            })

            return Disposables.create()
        }
    }

    func insert<T: BaseEntity>(model: T) -> Observable<[AnyHashable: Any]> {
        return Observable.create { observer in
            model.id = ""
            self.datasource.insert(model.toDict(), completion: { (item, error) in

                guard error == nil else {
                    try! BaseDataProvider.instance.store?.deleteItems(withIds: [model.id], table: self.datasource.name)
                    observer.onError(error!)
                    return
                }

                observer.onNext(item! as [AnyHashable: Any])
                observer.onCompleted()
            })

            return Disposables.create()
        }
    }

    func updateAndPushIfOnline<T: BaseEntity>(model: T) -> Observable<Bool> {
        return Observable.create { observer in
            self.datasource.update(model.toDict(), completion: { (error) -> Void in

                guard error == nil else {
                    observer.onError(error!)
                    return
                }

                BaseDataProvider.instance.pushIfOnline(completion: {
                    (error) -> Void in

                    guard error == nil else {
                        observer.onError(error!);
                        return
                    }

                    observer.onNext(true)
                    observer.onCompleted()
                })
            })

            return Disposables.create()
        }
    }

    func insertAndPushIfOnline<T: BaseEntity>(model: T) -> Observable<[AnyHashable: Any]> {
        return Observable.create { observer in
            model.id = ""

            self.datasource.insert(model.toDict(), completion: { (item, error) in
                guard error == nil else {
                    try! BaseDataProvider.instance.store?.deleteItems(withIds: [model.id], table: self.datasource.name)
                    observer.onError(error!)
                    return
                }

                BaseDataProvider.instance.pushIfOnline(completion: {
                    (error) -> Void in

                    guard error == nil else {
                        try! BaseDataProvider.instance.store?.deleteItems(withIds: [model.id], table: self.datasource.name)
                        observer.onError(error!)
                        return
                    }

                    observer.onNext(item! as [AnyHashable: Any])
                    observer.onCompleted()
                })
            })

            return Disposables.create()
        }
    }

    func delete<T: BaseEntity>(model: T) -> Observable<Bool> {
        return Observable.create { observer in
            self.datasource.delete(model.toDict(), completion: { (error) -> Void in

                guard error == nil else {
                    observer.onError(error!)
                    return
                }

                observer.onNext(true)
                observer.onCompleted()
            })

            return Disposables.create()
        }
    }

    func deleteAndPushIfOnline<T: BaseEntity>(model: T) -> Observable<Bool> {
        return Observable.create { observer in
            self.datasource.delete(model.toDict(), completion: { (error) -> Void in
                if let e = error {
                    observer.onError(e)
                    return
                } else {
                    BaseDataProvider.instance.pushIfOnline(completion: {
                        (error) -> Void in

                        guard error == nil else {
                            observer.onError(error!)
                            return
                        }

                        observer.onNext(true)
                        observer.onCompleted()
                    })
                }
            })

            return Disposables.create()
        }
    }

    // END General

    // returning model
    func lookUp(id: String) -> BaseEntity? {
        do {
            return try (BaseDataProvider.instance.store as! Store).getRecordForTable(table: self.datasource.name, itemId: id) as? BaseEntity
        } catch {
            return nil
        }
    }

    func filter(query: MSQuery) -> [BaseEntity] {
        var items: [BaseEntity] = []

        do {
            for item in try (BaseDataProvider.instance.store?.read(with: query).items)! {
                let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
                let className = String(format: "%@.%@", appName, self.datasource.name.replacingOccurrences(of: "MOB_", with: ""))
                let entityClass = NSClassFromString(className) as! BaseEntity.Type
                items.append(entityClass.init(dictionary: item as NSDictionary))
            }

            return items
        } catch {
            return items
        }
    }

    func filter(predicate: NSPredicate) -> [BaseEntity] {
        return self.filter(query: self.datasource.query(with: predicate))
    }

    var items: [BaseEntity] {
        return self.filter(query: self.datasource.query())
    }
    // END
}

public extension SyncDataAccessObject {
    var priority: Int {
        get {
            return 1000
        }
    }

    var datasource: MSSyncTable {
        get {
            let name = String(format: "%@%@", arguments: ["MOB_", (String(describing: Model.self)).replacingOccurrences(of: ".Type", with: "")])
            return BaseDataProvider.instance.client!.syncTable(withName: name)
        }
    }

    var isOnline: Bool {
        get {
            return false
        }
    }

    func filterAsync(query: MSQuery) -> Observable<[Model]> {
        return Observable.create { observer in
            var items: [Model] = []

            do {
                for item in try (BaseDataProvider.instance.store?.read(with: query).items)! {
                    let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
                    let className = String(format: "%@.%@", appName, self.datasource.name.replacingOccurrences(of: "MOB_", with: ""))
                    let entityClass = NSClassFromString(className) as! Model.Type
                    items.append(entityClass.init(dictionary: item as NSDictionary))
                }

                observer.onNext(items)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    func filterAsync(predicate: NSPredicate) -> Observable<[Model]> {
        return self.filterAsync(query: self.datasource.query(with: predicate))
    }

    func toListAsync() -> Observable<[Model]> {
        return self.filterAsync(query: self.datasource.query())
    }

    func filter(query: MSQuery) -> [Model] {
        var items: [Model] = []

        do {
            for item in try (BaseDataProvider.instance.store?.read(with: query).items)! {
                let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
                let className = String(format: "%@.%@", appName, self.datasource.name.replacingOccurrences(of: "MOB_", with: ""))
                let entityClass = NSClassFromString(className) as! Model.Type
                items.append(entityClass.init(dictionary: item as NSDictionary))
            }

            return items
        } catch {
            return items
        }
    }

    func filter(predicate: NSPredicate) -> [Model] {
        return self.filter(query: self.datasource.query(with: predicate))
    }

    func lookUp(id: String) -> Model? {
        do {
            if let entity = try (BaseDataProvider.instance.store as! Store).getRecordForTable(table: self.datasource.name, itemId: id) {
                return Model.init(dictionary: (entity as! BaseEntity).toDict() as NSDictionary)
            }

            return nil
        } catch {
            return nil
        }
    }

    func lookUp(predicate: NSPredicate) -> Model? {
        return self.filter(predicate: predicate).first
    }

    func lookUpAsync(id: String) -> Observable<Model?> {
        return Observable.create { observer in
            observer.onNext(self.lookUp(id: id))
            observer.onCompleted()
            return Disposables.create()
        }
    }

    func lookUpAsync(predicate: NSPredicate) -> Observable<Model?> {
        return Observable.create { observer in
            observer.onNext(self.lookUp(predicate: predicate))
            observer.onCompleted()
            return Disposables.create()
        }
    }

    var items: [Model] {
        return self.filter(query: self.datasource.query())
    }
}
