import NMDEF_Sync
import NMDEF_Base
import RxSwift
import RxCocoa

open class BaseDataLoaderViewModel<T>: BaseViewModel {
    open var datasource: Observable<T> { get{ return .empty() } }
    public var isEmpty = BehaviorRelay<Bool>(value: true)
    private var _disposable: Disposable?

    required public init() {
        super.init()

        self.rx.viewCreated += { _ in
            self.loadData()
        }
    }

    open func loadData() {
        onBeforeLoadData()

        _disposable?.dispose()
        _disposable = datasource
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { self.loadData(data: $0) }, onError: { self.onError(error: $0) }, onCompleted: { self.onCompleted() })
    }

    open func loadData(data: T) {

    }

    open func onBeforeLoadData() {
        isLoading.val = true
    }

    open func onError(error: Error) {
        print("Error has occured in \(String(describing: self)): \(error)")
    }

    open func onCompleted() {
        isLoading.val = false
    }
}
