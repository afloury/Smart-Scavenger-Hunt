import Foundation
import Alamofire
import SwiftyJSON

class API {
    
    var urlBaseLocationRestriction = "http://172.30.1.208:5002/"
    var urlBaseRouter = "http://172.30.1.208:5001/"
    
    
    func sendPhoto(token: String, imageData: Data, completion: @escaping (_ result: String)->()) {
        let headers: HTTPHeaders = [
            "Authentication": token
        ]
        Alamofire.upload(imageData, to: "\(urlBaseRouter)picture/", headers: headers).responseJSON { response in
            //debugPrint(response)
            if let json = response.result.value {
                //print("JSON: \(json)")
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
}
