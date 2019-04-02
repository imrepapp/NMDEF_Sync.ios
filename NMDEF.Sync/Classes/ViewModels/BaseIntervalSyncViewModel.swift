import NMDEF_Base
import RxSwift

open class BaseIntervalSyncViewModel<T>: BaseSyncViewModel<T> {
    open var syncInterval: Double {
        get {
            return 10
        }
    }

    private var _syncTimer: Disposable?

    public required init() {
        super.init()

        _syncTimer = Observable<Int>.interval(syncInterval, scheduler: MainScheduler.instance)
                .subscribe {
                    BaseDataProvider.instance.synchronize(groupName: String(describing: self))
                }
    }

    deinit {
        _syncTimer?.dispose()
    }
}