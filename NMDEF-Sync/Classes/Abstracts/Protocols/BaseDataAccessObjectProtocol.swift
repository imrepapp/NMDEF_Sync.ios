import MicrosoftAzureMobile_Xapt

public protocol BaseDataAccessObjectProtocol {
    var datasource: MSSyncTable { get }
    var priority: Int { get }
    var isOnline: Bool { get }
}

public protocol DataAccessObjectProtocol: BaseDataAccessObjectProtocol {
    associatedtype Model: BaseEntity
}
