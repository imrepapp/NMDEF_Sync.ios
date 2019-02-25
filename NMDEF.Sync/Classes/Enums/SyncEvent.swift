import RxBus
import RxSwift

public struct SyncEvent {
    public struct Synced: BusEvent {
        public let item: SynchronizationQueueItem
    }
}
