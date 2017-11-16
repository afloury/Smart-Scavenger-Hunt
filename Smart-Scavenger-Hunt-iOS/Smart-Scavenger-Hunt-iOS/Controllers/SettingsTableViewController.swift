import UIKit
import KeychainSwift

class SettingsTableViewController: UITableViewController {

    let keychain = KeychainSwift()
    var numberOfSection = 1
    var homeVC: HomeViewController!
    let api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let home = tabBarController?.viewControllers![0] as? HomeViewController {
            homeVC = home
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if keychain.get("token") != nil {
            numberOfSection = 2
        } else {
            numberOfSection = 1
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSection
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        if homeVC.hadMission {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            // Disconnect Team
            Alert.show(controller: self, message: "Disconnect your team ?", okAction: UIAlertAction.init(title: "Yes", style: .default, handler: { (alert: UIAlertAction!) in
                self.keychain.clear()
                self.numberOfSection = 1
                self.homeVC.hadMission = false
                self.tabBarController?.selectedIndex = 0
                tableView.reloadData()
            }), cancelAction: true)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            // Leave mission (penalty)
            
            Alert.show(controller: self, message: "Are you sure to leave the current mission ?", okAction: UIAlertAction.init(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) in
                self.api.leaveMission()
                self.homeVC.hadMission = false
                tableView.reloadData()
                Alert.show(controller: self, message: "Your team loose 3 points ☹️", title: "Mission left", okAction: UIAlertAction.init(title: "Ok", style: .default, handler: {(alert: UIAlertAction!) in
                    self.tabBarController?.selectedIndex = 0
                }))
            }), cancelAction: true)
        }
    }
}
