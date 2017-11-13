//
//  RegisterTeamViewController.swift
//  Smart-Scavenger-Hunt-iOS
//
//  Created by student on 09/11/2017.
//  Copyright © 2017 student. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift

class RegisterTeamViewController: UIViewController {

    @IBOutlet weak var startSession: UIButton!
    @IBOutlet weak var teamTextField: UITextField!
    var lrID = ""
    var urlBaseRouter = "http://172.30.1.208:5001/"
    let keychain = KeychainSwift()
    var tabBarCtrl: UITabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSession.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startSession(_ sender: Any) {
        if (teamTextField.text != nil) {
            let parameters: Parameters = [
                "name": teamTextField.text!
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
                    } else {
                        if let message = json["message"].string {
                            let alertController = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
                            let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: {(alert: UIAlertAction!) in
                            })
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                    //print("JSON: \(json)")
                case .failure(let error):
                    print(error)
                }
                self.view.removeFromSuperview()
                self.tabBarCtrl.selectedIndex = 0
            }
        } else {
            // nom d'équipe vide
        }
    }
    
    @IBAction func cancelView(_ sender: Any) {
        if let superView = self.view.superview as? ScanViewController {
            superView.idRegion = ""
        }
        self.view.removeFromSuperview()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
