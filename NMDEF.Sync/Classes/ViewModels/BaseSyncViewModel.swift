import NMDEF_Base
import NMDEF_Sync
import RxBus
import RxSwift

open class BaseSyncViewModel<T>: BaseDataLoaderViewModel<T> {
    open var dependencies: [BaseDataAccessObjectProtocol.Type] {
        get {
            return []
        }
    }

    public required init() {
        super.init()

        if dependencies.count > 0 {
            BaseDataProvider.instance.addToSyncGroup(syncGroupName: String(describing: self), daoList: dependencies)
            BaseDataProvider.instance.synchronize(groupName: String(describing: self))
            RxBus.shared.asObservable(event: SyncEvent.Synced.self).subscribe { event in
                if event.element!.item.status == .success {
                    self.loadData()
                }
            } => disposeBag
        }
    }
}
