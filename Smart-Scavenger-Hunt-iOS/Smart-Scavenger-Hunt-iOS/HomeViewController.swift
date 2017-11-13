import UIKit
import KeychainSwift

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let keychain = KeychainSwift()
    
    @IBOutlet weak var titleTop: UILabel!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var titleTableV: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("viewDidAppear")
        if let token = keychain.get("token") {
            titleTop.text = "Hey"
            messageTitle.text = "Go to the withdrawal point to get your mission"
            titleTableV.isHidden = false
            tableView.isHidden = false
        } else {
            titleTop.text = "Hello"
            messageTitle.text = "Welcome to Scavenger Hunt\nto start a session go near to registration point"
            // TODO Uncomment
            titleTableV.isHidden = true
            tableView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
        cell.textLabel?.text = "hey"
        cell.detailTextLabel?.text = "ho"
        return cell
    }
    
}
