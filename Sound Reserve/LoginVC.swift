//
//  LoginVC.swift
//  Sound Reserve
//
//  Created by Admin on 2020/12/15.
//

import UIKit
import StoreKit

class LoginVC: UIViewController {

    @IBOutlet weak var btnSpotify: UIButton!
    @IBOutlet weak var btnApple: UIButton!
    
    private let playURI = "spotify:album:1htHMnxonxmyHdKE2uDFMR"
    private let trackIdentifier = "spotify:track:32ftxJzxMPgUFCM6Km9WTS"
    private let name = "Demo"
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                }
            }
        }
    }
    
    var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.btnSpotify.layer.cornerRadius = 4
        self.btnSpotify.layer.borderWidth = 1
        self.btnSpotify.layer.borderColor = UIColor.gray.cgColor
        self.btnApple.layer.cornerRadius = 4
        self.btnApple.layer.borderWidth = 1
        self.btnApple.layer.borderColor = UIColor.gray.cgColor
    }
    
    @IBAction func onClickSpotify(_ sender: Any) {
        if appRemote?.isConnected == false {
            if appRemote?.authorizeAndPlayURI(playURI) == false {
                // The Spotify app is not installed, present the user with an App Store page
                showAppStoreInstall()
            }
        } else {
            
        }
    }
    
    @IBAction func onClickApple(_ sender: Any) {
        
    }
    
    // MARK: - Error & Alert
    func showError(_ errorDescription: String) {
        let alert = UIAlertController(title: "Error!", message: errorDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
        }
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: SKStoreProductViewControllerDelegate
extension LoginVC: SKStoreProductViewControllerDelegate {
    private func showAppStoreInstall() {
        if TARGET_OS_SIMULATOR != 0 {
            presentAlert(title: "Simulator In Use", message: "The App Store is not available in the iOS simulator, please test this feature on a physical device.")
        } else {
            let loadingView = UIActivityIndicatorView(frame: view.bounds)
            view.addSubview(loadingView)
            loadingView.startAnimating()
            loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            let storeProductViewController = SKStoreProductViewController()
            storeProductViewController.delegate = self
            storeProductViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: SPTAppRemote.spotifyItunesItemIdentifier()], completionBlock: { (success, error) in
                loadingView.removeFromSuperview()
                if let error = error {
                    self.presentAlert(
                        title: "Error accessing App Store",
                        message: error.localizedDescription)
                } else {
                    self.present(storeProductViewController, animated: true, completion: nil)
                }
            })
        }
    }

    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
