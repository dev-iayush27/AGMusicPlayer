import Foundation
import UIKit

class SongsListRouter {
    
    /// Initialize SongsList module
    static func assembleModule(bundle: [String: Any]) -> UIViewController {
        let viewController = SongsListViewController(nibName: "SongsListViewController", bundle: nil)
        
        let presenter = SongsListPresenter()
        let router = SongsListRouter()
        let service = SongsListService()
        
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
