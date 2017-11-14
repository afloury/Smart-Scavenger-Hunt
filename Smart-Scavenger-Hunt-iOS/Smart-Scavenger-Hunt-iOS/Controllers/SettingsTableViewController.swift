import UIKit
import KeychainSwift

class SettingsTableViewController: UITableViewController {

    let keychain = KeychainSwift()
    var numberOfSection = 1
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if keychain.get("token") != nil {
            numberOfSection = 2
            tableView.reloadData()
        } else {
            numberOfSection = 1
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSection
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            print("disconnect")
            keychain.clear()
            numberOfSection = 1
            tableView.reloadData()
            if let home = tabBarController?.viewControllers![0] as? HomeViewController {
                home.hadMission = false
            }
            tabBarController?.selectedIndex = 0
        }
    }
}
