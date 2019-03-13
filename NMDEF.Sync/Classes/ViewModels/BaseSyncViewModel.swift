import MicrosoftAzureMobile_Xapt
import NMDEF_Base
import NMDEF_Sync
import RxBus
import RxSwift
import RxCocoa

open class BaseSyncViewModel<T>: BaseDataLoaderViewModel<T> {
    private var _isFirstSync = false
    private var _isLoadedFromLocal = false
    private var _syncObserver: Disposable?

    public var isSyncing = BehaviorRelay<Bool>(value: false)

    open var dependencies: [BaseDataAccessObjectProtocol.Type] {
        get {
            return []
        }
    }

    public required init() {
        super.init()

        if dependencies.count > 0 {
            do {
                if let r = try BaseDataProvider.instance.store?.read(with: MSQuery(
                        syncTable: BaseDataProvider.instance.client?.syncTable(withName: (BaseDataProvider.instance.store?.configTableName() as! String)),
                        predicate: NSPredicate(format: "table = %@", argumentArray: [
                            String.init(format: "MOB_%@", arguments: [
                                String(describing: dependencies.first).components(separatedBy: ".").last!.replacingOccurrences(of: "DAO)", with: "")
                            ])
                        ]))).items.first {
                    if _isLoadedFromLocal && isLoading.val {
                        isLoading.val = false
                    }
                } else {
                    _isFirstSync = true
                }
            } catch {
                // ignore
            }

            BaseDataProvider.instance.addToSyncGroup(syncGroupName: String(describing: self), daoList: dependencies)

            self.onBeforeSync()

            BaseDataProvider.instance.synchronize(groupName: String(describing: self))
            _syncObserver = RxBus.shared.asObservable(event: SyncEvent.Synced.self).subscribe { event in
                if event.element!.item.status == .success {
                    self.loadData()
                }

                self.onAfterSync()
                self._isFirstSync = false
                self._syncObserver?.dispose()
            }
        }
    }

    open func onBeforeSync() {
        isSyncing.val = true
    }

    open func onAfterSync() {
        isSyncing.val = false
    }

    open override func onBeforeLoadData() {
        if !isSyncing.val {
            isLoading.val = true
        }
    }

    open override func onCompleted() {
        if !_isFirstSync {
            isLoading.val = false
        }

        _isLoadedFromLocal = true
    }
}
