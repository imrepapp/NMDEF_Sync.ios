import MicrosoftAzureMobile_Xapt
import RxSwift

public protocol DataAccessObject {
    associatedtype Model: BaseEntity

    var datasource: MSTable { get }
}

public protocol BaseSyncDataAccessObject {
    var datasource: MSSyncTable { get }
    var priority: Int { get }
    var isOnline: Bool { get }
}

public protocol SyncDataAccessObject: BaseSyncDataAccessObject {
    associatedtype Model: BaseEntity
}
