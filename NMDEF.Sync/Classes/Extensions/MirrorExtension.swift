import Foundation

public extension Mirror {

    static var loadedClasses: [AnyClass] = []

    func toDictionary() -> [String: AnyObject] {
        var dict = [String: AnyObject]()

        // Properties of this instance:
        for attr in self.children {
            if let propertyName = attr.label {
                dict[propertyName] = attr.value as AnyObject
            }
        }

        // Add properties of superclass:
        if let parent = self.superclassMirror {
            for (propertyName, value) in parent.toDictionary() {
                dict[propertyName] = value
            }
        }

        return dict
    }
}
