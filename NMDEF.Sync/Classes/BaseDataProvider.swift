import MicrosoftAzureMobile_Xapt
import RxBus
import RxSwift

public class BaseDataProvider: NSObject {
    public static let instance = BaseDataProvider()
    public var client: MSClient?
    public var store: MSSyncContextDataSource?

    private var _syncQueue: SynchronizationQueue = SynchronizationQueue.instance

    var rowCount: Int?
    let pullSettings: MSPullSettings = MSPullSettings.init(pageSize: 1000)

    var syncDAOs: [BaseDataAccessObjectProtocol] = []
    var syncGroups: [String: [String]] = [:]
    var skipTables: [String] = []

    var count: UInt32 = 0
    var allClasses: AutoreleasingUnsafeMutablePointer<AnyClass>

    public func initialization(_ context: DataProviderContext) -> Observable<Void> {
        return Observable.create { observer in
            if let url = URL(string: context.apiUrl) {
                self.client = MSClient(applicationURL: url).withFilter(ClientFilter())
            } else {
                fatalError("Url of the API is mandatory.")
            }

            self.store = Store()

            if let s = self.store {
                self.client!.syncContext = MSSyncContext(delegate: nil, dataSource: s, callback: nil)
                self.client?.currentUser = MSUser()
                self.client!.currentUser?.mobileServiceAuthenticationToken = context.token
            }

            //self.collect()
            self.syncDAOs.sort(by: { $0.priority < $1.priority })

            // add handlers
            self.addHandler([
                DeviceIdHandler(),
                InsertEntityHandler(),
                UpdateEntityHandler(),
                DeleteEntityHandler()
            ])

            if self.syncDAOs.count == 0 {
                fatalError("There aren't any DAO classes.")
            }

            var c = self.syncDAOs.filter({ String(describing: type(of: $0)) == "ModDateTimesDAO" }).first

            self._syncQueue.syncAction = self.syncQueueItem

            if let modDateTimeDAO = self.syncDAOs.filter({ String(describing: type(of: $0)) == "ModDateTimesDAO" }).first {
                let oldDates = modDateTimeDAO.items
                modDateTimeDAO.syncTable()
                        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                        .subscribe(onError: {
                            observer.onError($0)
                        }, onCompleted: {
                            if oldDates.count > 0 {
                                for st in modDateTimeDAO.items {
                                    if let oldDate = oldDates.filter({ $0.id == st.id }).first, (oldDate.toDict()[MSSystemColumnUpdatedAt] as! Date) == (st.toDict()[MSSystemColumnUpdatedAt] as! Date) {
                                        self.skipTables.append(oldDate.id)
                                    }
                                }
                            }

                            observer.onCompleted()
                        })
            } else {
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    private override init() {
        allClasses = objc_copyClassList(&count)!
    }

    public func syncTable(table: MSSyncTable, query: MSQuery?, label: String?) -> Observable<Void> {
        return Observable.create { observer in
            let q = query ?? table.query()
            let l = label ?? "all"

            print("Sync of \(table.name) has been started...")

            table.pull(with: q, queryId: l, settings: self.pullSettings, completion: {
                (error) -> Void in

                if let err = error {
                    print("Error: \(error!.localizedDescription)")
                    observer.onError(err)
                } else {
                    print("\(table.name) has been synced")
                }

                observer.onCompleted()
            })

            return Disposables.create()
        }
    }

    public static func DAO<T: DataAccessObjectProtocol>(_ dao: T.Type) -> T {
        let className = String(describing: T.self).replacingOccurrences(of: ".Type", with: "")
        if let d = instance.syncDAOs.filter({ String(describing: type(of: $0)) == String(describing: T.self) }).first {
            return d as! T
        }

        fatalError("There is no such DAO: \(className)")
    }

    public func pushIfOnline(completion: MSSyncBlock?) {
        NetworkManager.isReachable { _ in
            self.client?.syncContext?.push(completion: completion)
        }
    }

    private func collect() {
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;
        var sd: [String: BaseDataAccessObjectProtocol] = [:]

        for n in 0..<count {
            let someClass: AnyClass = allClasses[Int(n)]

            if (String(describing: someClass).hasSuffix("DAO")) {
                let c = (someClass as! NSObject.Type).init()

                if !(c as! BaseDataAccessObjectProtocol).isOnline {
                    syncDAOs.append(c as! BaseDataAccessObjectProtocol)
                }

                continue
            }

            for t in [GetHandler.self, PostHandler.self, PatchHandler.self, DeleteHandler.self, CustomHandler.self] {
                guard let someSuperClass = class_getSuperclass(someClass), String(describing: someSuperClass) == String(describing: t) else {
                    continue
                }
                ClientFilter.handlers.append((someClass as! BaseHandler.Type).init())
                break
            }
        }
    }

    private func subclasses<T>(of theClass: T) -> [T] {
        var result: [T] = []

        for n in 0..<count {
            let someClass: AnyClass = allClasses[Int(n)]
            guard let someSuperClass = class_getSuperclass(someClass), String(describing: someSuperClass) == String(describing: theClass) else {
                continue
            }
            result.append(someClass as! T)
        }

        return result
    }

    public func addToSyncGroup(syncGroupName: String, daoList: [BaseDataAccessObjectProtocol.Type]) {
        for daoType in daoList {
            addToSyncGroup(syncGroupName: syncGroupName, daoName: String(describing: daoType))
        }
    }

    public func addToSyncGroup(syncGroupName: String, daoName: String) {
        if let sg = syncGroups[syncGroupName], !sg.contains(daoName) {
            syncGroups[syncGroupName]?.append(daoName)
        } else {
            syncGroups[syncGroupName] = [daoName]
        }
    }

    public func addGroupToSyncQueue(groupName: String?, priority: SynchronizationPriority, isVisible: Bool) {
        _syncQueue.add(group: groupName, priority: priority, isVisible: isVisible)
    }

    private func syncQueueItem(syncItem: SynchronizationQueueItem) -> Observable<Void> {
        if syncItem.group == nil || syncGroups[syncItem.group ?? ""] != nil {
            var daos: [Observable<Void>] = []
            var sd = syncItem.group != nil ? syncDAOs.filter({ syncGroups[syncItem.group!]!.contains(String(describing: type(of: $0))) }) : syncDAOs
            for dao in sd.sorted(by: { $0.priority < $1.priority }) {
                daos.append(dao.syncTable().catchErrorJustReturn(()))
            }

            return Observable.concat(daos)
        }

        return Observable.empty()
    }

    public func addDAO(_ daos: [BaseDataAccessObjectProtocol]) {
        for var d in daos {
            addDAO(dao: d)
        }
    }

    public func addDAO(dao: BaseDataAccessObjectProtocol) {
        syncDAOs.append(dao)
    }

    public func addHandler(_ handlers: [BaseHandler]) {
        for var h in handlers {
            addHandler(handler: h)
        }
    }

    public func addHandler(handler: BaseHandler) {
        ClientFilter.handlers.append(handler)
    }

    public var lastSyncTime: Date? {
        get {
            if _syncQueue.lastSuccessItem != nil {
                return _syncQueue.lastSuccessItem?.modifiedAt
            } else {
                return nil
            }
        }
    }

    public var lastSyncDuration: TimeInterval? {
        get {
            if _syncQueue.lastSuccessItem != nil {
                return _syncQueue.lastSuccessItem?.modifiedAt.timeIntervalSince1970
            } else {
                return nil
            }
        }
    }

    public var isInProgress: Bool {
        get {
            return _syncQueue.hasRunningTask
        }
    }
}

public struct DataProviderContext {
    let apiUrl: String
    let token: String

    public init(apiUrl: String, token: String) {
        self.apiUrl = apiUrl
        self.token = token
    }
}
