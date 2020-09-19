import Foundation
import UIKit

class SplashRouter {
    
    /// Initialize Splash module
    static func assembleModule(bundle: [String: Any]) -> UIViewController {
        let viewController = SplashViewController(nibName: "SplashViewController", bundle: nil)
        
        let presenter = SplashPresenter()
        let router = SplashRouter()
        let service = SplashService()
        
        presenter.service = service
        presenter.viewController = viewController
        presenter.router = router
        
        viewController.bundle = bundle
        viewController.presenter = presenter
        
        return viewController
    }
    
    func navigateTo(destination: Destination, bundle: [String: Any]) {
        RootRouter().navigate(to: destination, bundle: bundle)
    }
}
