import MicrosoftAzureMobile_Xapt
import NMDEF_Base
import NMDEF_Sync
import RxBus
import RxSwift
import RxCocoa

open class BaseSyncViewModel<T>: BaseDataLoaderViewModel<T> {
    private var _isLoadedFromLocal = false
    private var _isFirstSync = false
    private var _isSynced = false
    private var _syncObserver: Disposable?

    public var isSyncing = BehaviorRelay<Bool>(value: false)

    open var dependencies: [BaseDataAccessObjectProtocol.Type] {
        get {
            return []
        }
    }

    open func onBeforeSync() {
        isSyncing.val = true
    }

    open func onAfterSync() {
        isSyncing.val = false
    }

    open override func onBeforeLoadData() {
        if !_isSynced {
            isLoading.val = true
        }

        if dependencies.count > 0 && !_isSynced {
            do {
                if try BaseDataProvider.instance.store?.read(with: MSQuery(
                        syncTable: BaseDataProvider.instance.client?.syncTable(withName: (BaseDataProvider.instance.store?.configTableName() as! String)),
                        predicate: NSPredicate(format: "table = %@", argumentArray: [
                            String.init(format: "MOB_%@", arguments: [
                                String(describing: dependencies.first).components(separatedBy: ".").last!.replacingOccurrences(of: "DAO)", with: "")
                            ])
                        ]))).items.first == nil {
                    _isFirstSync = true
                }
            } catch {
                // ignore
            }

            BaseDataProvider.instance.addToSyncGroup(syncGroupName: String(describing: self), daoList: self.dependencies)
            self.onBeforeSync()
            BaseDataProvider.instance.synchronize(groupName: String(describing: self))

            _syncObserver = RxBus.shared.asObservable(event: SyncEvent.Synced.self)
                    .observeOn(MainScheduler.instance)
                    .subscribe { event in
                        switch event.element!.item.status {
                        case .success, .canceled:
                            self._isSynced = true
                            self._isFirstSync = false
                            self.onAfterSync()
                            self._syncObserver?.dispose()
                            self.loadData()
                            break
                        case .inProgress, .requested, .start:
                            //ignore
                            break
                        }
                    }
        }
    }

    open override func onCompleted() {
        if !_isFirstSync && _isLoadedFromLocal {
            isLoading.val = false
        }

        _isLoadedFromLocal = true
    }
}
