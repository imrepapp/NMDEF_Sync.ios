import NMDEF_Sync
import NMDEF_Base
import RxSwift
import RxCocoa

open class BaseDataLoaderViewModel<T>: BaseViewModel {
    open var datasource: Observable<T> { get{ return .empty() } }
    public var isLoading = BehaviorRelay<Bool>(value: false)
    public var isEmpty = BehaviorRelay<Bool>(value: true)
    private var _disposable: Disposable?

    public required init() {
        super.init()
        loadData()
    }

    public func loadData() {
        isLoading.val = true

        _disposable?.dispose()
        _disposable = datasource
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe(onNext: { self.loadData(data: $0) }, onError: { self.onError(error: $0) }, onCompleted: { self.onCompleted() })
    }

    open func loadData(data: T) {

    }

    open func onError(error: Error) {
        print("Error has occured in \(String(describing: self)): \(error)")
    }

    open func onCompleted() {
        isLoading.val = false
    }
}
