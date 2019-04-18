//
// Created by Attila AMBRUS on 2019-04-18.
//

import MicrosoftAzureMobile_Xapt
import NMDEF_Base
import RxSwift
import EVReflection

public extension DataAccessObject {
    var datasource: MSTable {
        get {
            return BaseDataProvider.instance.client!.table(withName: String(describing: Model.self))
        }
    }

    func update<T: BaseEntity>(model: T) -> Single<Bool> {
        return Single<Bool>.create { single in
            self.datasource.update(model.toDict(), completion: { (result, error) in
                guard error == nil else {
                    single(.error(error!))
                    return
                }

                single(.success(true))
            })

            return Disposables.create()
        }
    }

    func insert<T: BaseEntity>(model: T) -> Single<[AnyHashable: Any]> {
        return Single<[AnyHashable: Any]>.create { single in
            self.datasource.update(model.toDict(), completion: { (result, error) in
                guard error == nil else {
                    single(.error(error!))
                    return
                }

                if let item = result {
                    single(.success(item))
                    return
                }

                single(.error(Parsing.error(msg: "Insert was unsuccessful.")))
            })

            return Disposables.create()
        }
    }

    func filterAsync(predicate: NSPredicate) -> Single<[Model]> {
        return Single<[Model]>.create() { single in
            self.datasource.read(with: predicate, completion: { (results, error) in
                guard error == nil else {
                    single(.error(error!))
                    return
                }

                var r: [Model] = []

                if let items = results?.items {
                    for item in items {
                        let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
                        let className = String(format: "%@.%@", appName, self.datasource.name)
                        let entityClass = NSClassFromString(className) as! Model.Type
                        r.append(entityClass.init(dictionary: item as NSDictionary))
                    }
                }

                single(.success(r))
            })

            return Disposables.create()
        }
    }
}
