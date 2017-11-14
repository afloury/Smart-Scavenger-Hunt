import UIKit

class Alert {
    
    
    
    static func show(controller: UIViewController, message: String, title: String? = nil, buttonTitle: String = "Ok") {
        let alertController = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: buttonTitle, style: .default, handler: {(alert: UIAlertAction!) in
        })
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }
}
