import RxSwift

extension BaseDataProvider {
    public func synchronize() {
        self.addGroupToSyncQueue(groupName: nil, priority: .low, isVisible: true)
    }

    public func synchronize(priority: SynchronizationPriority) {
        self.addGroupToSyncQueue(groupName: nil, priority: priority, isVisible: true)
    }

    public func synchronize(isVisible: Bool) {
        self.addGroupToSyncQueue(groupName: nil, priority: .low, isVisible: isVisible)
    }

    public func synchronize(priority: SynchronizationPriority, isVisible: Bool) {
        self.addGroupToSyncQueue(groupName: nil, priority: priority, isVisible: isVisible)
    }

    public func synchronize(groupName: String) {
        self.addGroupToSyncQueue(groupName: groupName, priority: .normal, isVisible: false)
    }

    public func synchronize(groupName: String, isVisible: Bool) {
        self.addGroupToSyncQueue(groupName: groupName, priority: .normal, isVisible: isVisible)
    }

    public func synchronize(groupName: String, priority: SynchronizationPriority, isVisible: Bool) {
        self.addGroupToSyncQueue(groupName: groupName, priority: priority, isVisible: isVisible)
    }

    public func synchronizeAfter(seconds: Int, groupName: String, priority: SynchronizationPriority, isVisible: Bool) {

    }
}