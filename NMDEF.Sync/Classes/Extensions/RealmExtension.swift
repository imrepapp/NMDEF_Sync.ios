import Foundation
import RealmSwift
import MicrosoftAzureMobile_Xapt
import EVReflection

public extension Results {

    func get<T: Object>(offset: Int, limit: Int) -> Array<T> {
        if offset == -1 && limit == -1 {
            return Array(self) as! Array<T>
        }

        //create variables
        var lim = 0 // how much to take
        var off = 0 // start from
        var l: Array<T> = Array<T>() // results list

        //check indexes
        if off <= offset && offset < self.count - 1 {
            off = offset
        }
        if limit > self.count {
            lim = self.count
        } else {
            lim = limit
        }

        //do slicing
        for i in off..<lim {
            let dog = self[i] as! T
            l.append(dog)
        }

        //results
        return l
    }
}

extension BaseObject {
    public func toModel(data: NSDictionary) throws -> Self {
        if let id = data[MSSystemColumnId], (data[MSSystemColumnId] as? String)?.count != 0 {
            _ = (self as EVCustomReflectable).constructWith(value: try! (data as! [String: Any]).filter { $0.key != MSSystemColumnId })
        } else {
            _ = (self as EVCustomReflectable).constructWith(value: data)
        }

        return self
    }

    public func toDict() -> [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()
        var exit = false
        var otherSelf = Mirror(reflecting: self as RealmSwift.Object)

        repeat {
            for child in otherSelf.children {
                if let key = child.label {
                    dict[key] = (self as NSObject).value(forKey: key) as Any
                }
            }

            if otherSelf.superclassMirror != nil {
                otherSelf = otherSelf.superclassMirror as! Mirror
            } else {
                exit = true
            }
        } while !exit

        return dict
    }
}
