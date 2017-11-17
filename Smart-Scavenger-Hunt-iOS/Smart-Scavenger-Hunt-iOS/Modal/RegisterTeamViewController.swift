import UIKit
import Alamofire
import SwiftyJSON

class RegisterTeamViewController: UIViewController {

    @IBOutlet weak var startSession: UIButton!
    @IBOutlet weak var teamTextField: UITextField!
    var lrID = ""
    let api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSession.layer.cornerRadius = 5
    }
    
    @IBAction func startSession(_ sender: Any) {
        if (teamTextField.text != nil) {
            api.registerTeam(name: teamTextField.text!, lrID: lrID, completion: { (message) in
                if message != nil {
                    Alert.show(controller: self, message: message!)
                }
            })
            if let home = self.view.superview as? HomeViewController {
                home.displayInstructions()
            }
            self.view.removeFromSuperview()
        } else {
            Alert.show(controller: self, message: "Nom d'équipe vide")
        }
    }
    
    @IBAction func cancelView(_ sender: Any) {
        self.view.removeFromSuperview()
    }
}
