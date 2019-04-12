//
// Created by Attila AMBRUS on 2019-04-11.
//

public protocol IgnoredJSON {
    var ignoredJSONProperties: [String] { get }
}

public extension IgnoredJSON where Self: BaseEntity {
    var ignoredJSONProperties: [String] {
        return []
    }
}
