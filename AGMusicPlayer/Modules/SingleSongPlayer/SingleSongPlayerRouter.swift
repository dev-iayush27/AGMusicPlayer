import Foundation
import UIKit

class SingleSongPlayerRouter {
    
    /// Initialize SingleSongPlayer module
    static func assembleModule(bundle: [String: Any]) -> UIViewController {
        let viewController = SingleSongPlayerViewController(nibName: "SingleSongPlayerViewController", bundle: nil)
        
        let presenter = SingleSongPlayerPresenter()
        let router = SingleSongPlayerRouter()
        let service = SingleSongPlayerService()
        
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
