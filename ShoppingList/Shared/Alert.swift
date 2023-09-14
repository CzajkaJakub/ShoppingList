import UIKit

public class Alert {
    
    public static func displayErrorAlert(message: String) {
        let alertController = UIAlertController(title: Constants.error, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constants.ok, style: .default, handler: nil)
        alertController.addAction(okAction)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let currentWindow = windowScene.windows.first,
            let currentViewController = currentWindow.rootViewController {
             currentViewController.present(alertController, animated: true, completion: nil)
         }
    }
}
