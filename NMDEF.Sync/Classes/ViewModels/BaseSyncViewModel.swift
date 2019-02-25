import NMDEF_Base
import NMDEF_Sync
import RxBus
import RxSwift

open class BaseSyncViewModel<T>: BaseDataLoaderViewModel<T> {
    open var depencies: [BaseDataAccessObjectProtocol.Type] {
        get {
            return []
        }
    }

    public required init() {
        super.init()

        if depencies.count > 0 {
            BaseDataProvider.instance.addToSyncGroup(syncGroupName: String(describing: self), daoList: depencies)
            BaseDataProvider.instance.synchronize(groupName: String(describing: self))
            RxBus.shared.asObservable(event: SyncEvent.Synced.self).subscribe { event in
                if event.element!.item.status == .success {
                    self.loadData()
                }
            } => disposeBag
        }
    }
}
