import RxSwift

public enum SynchronizationPriority: Int {
    case low
    case normal
    case high
}

public enum SynchronizationStatus: Int {
    case requested
    case start
    case inProgress
    case success
    case canceled
}

public class SynchronizationQueue {
    public static let instance = SynchronizationQueue()

    private var _queue: [SynchronizationQueueItem] = []
    private var _enabled: Bool = true
    private var _currentProcess: Disposable?
    private var _currentItem: SynchronizationQueueItem?
    private var _disposebag: DisposeBag = DisposeBag()

    internal var syncAction: ((_ syncItem: SynchronizationQueueItem) -> Observable<Void>)?

    private init() {
        syncAction = nil
    }

    public func add(group: String?, priority: SynchronizationPriority, isVisible: Bool) {
        SynchronizationQueue.cancelAll()

        _queue.removeAll(where: { $0.status == .canceled && $0.group == group })
        _queue.append(SynchronizationQueueItem(group: group, priority: priority, isVisible: isVisible))
        runNextTask()
    }

    private func runNextTask() {
        if (_enabled) {
            var pendingItems = _queue.filter({ $0.status == .requested || $0.status == .canceled })
            pendingItems = pendingItems.sorted(by: {
                if $0.priority != $1.priority {
                    return $0.priority.rawValue > $1.priority.rawValue
                }

                return $0.createdAt < $1.createdAt
            })

            if let item = (pendingItems.filter({ $0.status == .requested }).first ?? pendingItems.filter({ $0.status == .canceled }).first) {
                _currentItem = item
                _currentItem?.status = .inProgress
                _currentProcess = syncAction!(_currentItem!).subscribe(onError: { error in
                    self._queue.removeAll(where: { $0.id == self._currentItem!.id })
                    print(error)
                }, onCompleted: {
                    self._currentItem?.status = .success
                })
                _currentProcess?.disposed(by: _disposebag)
            }
        }
    }

    public static func cancelAll() {
        cancelAll(priority: .high)
    }

    public static func cancelAll(priority: SynchronizationPriority) {
        instance._currentItem = nil
        instance._currentProcess?.dispose()
        for var sqi in instance._queue.filter({ ($0.status == .inProgress || $0.status == .start) && $0.priority.rawValue <= priority.rawValue }) {
            sqi.status = .canceled
        }
    }

    public static func removeAll() {
        cancelAll()
        instance._queue.removeAll(where: { $0.status == .canceled || $0.status == .requested })
    }

    public var hasRunningTask: Bool {
        get {
            return _queue.filter({ $0.status == .inProgress }).count > 0
        }
    }

    public var lastSuccessItem: SynchronizationQueueItem? {
        get {
            _queue.sort(by: { $0.modifiedAt > $1.modifiedAt })
            return _queue.first(where: { $0.status == .success })
        }
    }

}