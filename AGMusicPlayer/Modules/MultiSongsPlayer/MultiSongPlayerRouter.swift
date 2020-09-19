import Foundation
import UIKit

class MultiSongPlayerRouter {
    
    /// Initialize MultiSongPlayer module
    static func assembleModule(bundle: [String: Any]) -> UIViewController {
        let viewController = MultiSongPlayerViewController(nibName: "MultiSongPlayerViewController", bundle: nil)
        
        let presenter = MultiSongPlayerPresenter()
        let router = MultiSongPlayerRouter()
        let service = MultiSongPlayerService()
        
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
