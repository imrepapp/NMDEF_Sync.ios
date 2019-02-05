import RealmSwift
import RxSwift
import EVReflection
import MicrosoftAzureMobile

public extension BaseDataAccessObjectProtocol {
    // General
    public func syncTable() -> Observable<Void> {
        return self.syncTable(query: self.datasource.query())
    }

    public func syncTable(query: MSQuery, label: String? = nil) -> Observable<Void> {
        return BaseDataProvider.instance.syncTable(table: self.datasource, query: query, label: label)
    }

    public func update<T: BaseEntity>(model: T) -> Observable<Bool> {
        return Observable.create { observer in
            self.datasource.update(model.toDict(), completion: { (error) -> Void in
                if let e = error {
                    observer.onError(e)
                } else {
                    observer.onNext(true)
                }

                observer.onCompleted()
            })

            return Disposables.create()
        }
    }

    public func insert<T: BaseEntity>(model: T) -> Observable<[AnyHashable: Any]> {
        return Observable.create { observer in
            model.id = ""
            self.datasource.insert(model.toDict(), completion: { (item, error) in
                if let e = error {
                    try! BaseDataProvider.instance.store?.deleteItems(withIds: [model.id], table: self.datasource.name)
                    observer.onError(e)
                } else {
                    observer.onNext(item! as [AnyHashable: Any])
                }

                observer.onCompleted()
            })

            return Disposables.create()
        }
    }

    public func updateAndPushIfOnline<T: BaseEntity>(model: T) -> Observable<Bool> {
        return Observable.create { observer in
            self.datasource.update(model.toDict(), completion: { (error) -> Void in
                if let e = error {
                    observer.onError(e)
                    observer.onCompleted()
                } else {
                    BaseDataProvider.instance.pushIfOnline(completion: {
                        (error) -> Void in

                        if let e = error {
                            observer.onError(e)
                        } else {
                            observer.onNext(true)
                        }

                        observer.onCompleted()
                    })
                }
            })

            return Disposables.create()
        }
    }

    public func insertAndPushIfOnline<T: BaseEntity>(model: T) -> Observable<[AnyHashable: Any]> {
        return Observable.create { observer in
            model.id = ""
//            model.updatedAt = Date()
//            model.createdAt = Date()

            self.datasource.insert(model.toDict(), completion: { (item, error) in
                if let e = error {
                    try! BaseDataProvider.instance.store?.deleteItems(withIds: [model.id], table: self.datasource.name)
                    observer.onError(e)
                    observer.onCompleted()
                } else {
                    BaseDataProvider.instance.pushIfOnline(completion: {
                        (error) -> Void in

                        if let e = error {
                            try! BaseDataProvider.instance.store?.deleteItems(withIds: [model.id], table: self.datasource.name)
                            observer.onError(e)
                        } else {
                            observer.onNext(item! as [AnyHashable: Any])
                        }

                        observer.onCompleted()
                    })
                }
            })

            return Disposables.create()
        }
    }

    public func delete<T: BaseEntity>(model: T) -> Observable<Bool> {
        return Observable.create { observer in
            self.datasource.delete(model.toDict(), completion: { (error) -> Void in
                if let e = error {
                    observer.onError(e)
                } else {
                    observer.onNext(true)
                }

                observer.onCompleted()
            })

            return Disposables.create()
        }
    }

    public func deleteAndPushIfOnline<T: BaseEntity>(model: T) -> Observable<Bool> {
        return Observable.create { observer in
            self.datasource.delete(model.toDict(), completion: { (error) -> Void in
                if let e = error {
                    observer.onError(e)
                    observer.onCompleted()
                } else {
                    BaseDataProvider.instance.pushIfOnline(completion: {
                        (error) -> Void in

                        if let e = error {
                            observer.onError(e)
                        } else {
                            observer.onNext(true)
                        }

                        observer.onCompleted()
                    })
                }
            })

            return Disposables.create()
        }
    }

    // END General

    // returning model
    public func lookUp(id: String) -> BaseEntity? {
        do {
            return try (BaseDataProvider.instance.store as! Store).getRecordForTable(table: self.datasource.name, itemId: id) as? BaseEntity
        } catch {
            return nil
        }
    }

    public func filter(query: MSQuery) -> [BaseEntity] {
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

    public func filter(predicate: NSPredicate) -> [BaseEntity] {
        return self.filter(query: self.datasource.query(with: predicate))
    }

    public var items: [BaseEntity] {
        return self.filter(query: self.datasource.query())
    }
    // END
}

extension DataAccessObjectProtocol {
    public var priority: Int {
        get {
            return 1000
        }
    }

    public var datasource: MSSyncTable {
        get {
            return BaseDataProvider.instance.client!.syncTable(withName: String(format: "%@%@", arguments: ["MOB_", (String(describing: Model.self)).replacingOccurrences(of: ".Type", with: "")]))
        }
    }

    public var isOnline: Bool {
        get {
            return false
        }
    }
}
