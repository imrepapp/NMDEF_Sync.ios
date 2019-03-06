//
// Created by Attila AMBRUS on 2019-03-05.
//

import MicrosoftAzureMobile_Xapt

public extension Error {
    public var message: String? {
        get {
            do {
                if let data = ((((self as? NSError)?.userInfo[MSErrorPushResultKey] as? NSArray)?[0]) as? MSTableOperationError)?.description
                        .data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                    if let msg = json["message"] as? String {
                        return msg
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(self.localizedDescription)")
            }

            return nil
        }
    }
}
