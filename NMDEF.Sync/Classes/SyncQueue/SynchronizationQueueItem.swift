import RxBus

public struct SynchronizationQueueItem {
    private var _status: SynchronizationStatus

    public private(set) var id: String
    public private(set) var createdAt: Date
    public private(set) var modifiedAt: Date
    public private(set) var group: String?
    public private(set) var priority: SynchronizationPriority
    public var status: SynchronizationStatus {
        get { return _status }
        set {
            if (isCanceled && newValue != .canceled) {
                wasCanceled = true
            }

            _status = newValue
            modifiedAt = Date()

            RxBus.shared.post(event: SyncEvent.Synced(item: self))
        }
    }
    public var isVisible: Bool
    public var wasCanceled: Bool = false
    public var isCanceled: Bool { return status == .canceled }

    init(group: String?) {
        self.init(group: group, priority: .low)
    }

    init(group: String?, priority: SynchronizationPriority) {
        self.init(group: group, priority: priority, isVisible: false)
    }

    init(group: String?, priority: SynchronizationPriority, isVisible: Bool) {
        self.id = UUID().uuidString
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.group = group
        self.priority = priority
        self.isVisible = isVisible
        self._status = .requested
    }
}