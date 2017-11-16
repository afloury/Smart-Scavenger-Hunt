import UIKit

class Alert {
    
    
    
    static func show(controller: UIViewController, message: String, title: String? = nil, buttonTitle: String = "Ok", okAction: UIAlertAction = UIAlertAction.init(title: "Ok", style: .default, handler: {(alert: UIAlertAction!) in }), cancelAction: Bool = false) {
        let alertController = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        //let okAction = UIAlertAction.init(title: buttonTitle, style: .default, handler: {(alert: UIAlertAction!) in
        //})
        alertController.addAction(okAction)
        if cancelAction {
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .destructive, handler: {(alert: UIAlertAction!) in
            })
            alertController.addAction(cancelAction)
        }
        controller.present(alertController, animated: true, completion: nil)
    }
}
