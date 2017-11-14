import Foundation
import Alamofire
import SwiftyJSON
import KeychainSwift

class API {
    
    var urlBaseLocationRestriction = "" //"http://172.30.1.208:5002/"
    var urlBaseRouter = "" //"http://172.30.1.208:5001/"
    let keychain = KeychainSwift()
    var token = ""
    
    init() {
        self.urlBaseLocationRestriction = UserDefaults.standard.string(forKey: "location_restriction") ?? "vide"
        self.urlBaseRouter = UserDefaults.standard.string(forKey: "router") ?? "vide router"
        if let tokenKeychain = keychain.get("token") {
            token = tokenKeychain
        }
    }
    
    
    func sendPhoto(imageData: Data, completion: @escaping (_ result: String)->()) {
        let headers: HTTPHeaders = [
            "Authentication": token
        ]
        Alamofire.upload(imageData, to: "\(urlBaseRouter)picture/", headers: headers).responseJSON { response in
            //debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let jsonObject = JSON(json)
                let message =  jsonObject["message"].stringValue
                completion(message)
            }
        }
    }
    
    
    func loadUUID(completion: @escaping (_ uuidDelivery: String, _ uuidWithdrawal: String)->()) {
        Alamofire.request("\(urlBaseLocationRestriction)uuid/").responseJSON { response in
            if let json = response.result.value {
                let jsonObject = JSON(json)
                let uuidDelivery = jsonObject["depot"].stringValue
                let uuidWithdrawal = jsonObject["inscription_retrait"].stringValue
                completion(uuidDelivery, uuidWithdrawal)
            }
        }
    }
    
    func getMission(lrID: String, completion: @escaping (_ result: [String])->()) {
        let headers = [
            "X-SmartScavengerHunt-LRID": lrID,
            "Authentication": token
        ]
        Alamofire.request("\(urlBaseRouter)mission/", headers: headers).responseJSON { response in
            if let json = response.result.value {
                let jsonObject = JSON(json)
                var items = [String]()
                for element in jsonObject.arrayValue {
                    items.append(element.stringValue)
                }
                completion(items)
            }
        }
    }
    
    func registerTeam(name: String, lrID: String, completion: @escaping (_ message: String?)->()) {
        let parameters: Parameters = [
            "name": name
        ]
        let headers = [
            "X-SmartScavengerHunt-LRID": lrID
        ]
        Alamofire.request("\(urlBaseRouter)team/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let token = json["token"].string {
                    self.keychain.set(token, forKey: "token")
                    completion(nil)
                } else {
                    completion(json["message"].string)
                }
                //print("JSON: \(json)")
            case .failure(let error):
                print(error)
            }
        }
    }
}
