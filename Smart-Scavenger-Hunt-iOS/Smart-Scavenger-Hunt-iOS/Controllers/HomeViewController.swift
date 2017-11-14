import UIKit
import KeychainSwift

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let keychain = KeychainSwift()
    
    @IBOutlet weak var titleTop: UILabel!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var titleTableV: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var hadMission = false
    
    var items = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("viewDidAppear")
        if let token = keychain.get("token") {
            titleTop.text = "Hey"
            messageTitle.text = "Go to the withdrawal point to get your mission"
            titleTableV.isHidden = true
            tableView.isHidden = true
        } else {
            titleTop.text = "Hello"
            messageTitle.text = "Welcome to Scavenger Hunt\nto start a session go near to registration point"
            // TODO Uncomment
            titleTableV.isHidden = true
            tableView.isHidden = true
        }
        
        if hadMission {
            titleTop.text = "Let's begin !"
            messageTitle.text = "You need to get one of this:"
            titleTableV.isHidden = false
            tableView.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}
