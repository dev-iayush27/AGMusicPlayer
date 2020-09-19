import Foundation
import RxCocoa
import RxSwift
import UIKit

class SingleSongPlayerPresenter {
    weak var viewController: SingleSongPlayerViewController?
    var router: SingleSongPlayerRouter?
    var service: SingleSongPlayerService?
    private var disposeBag = DisposeBag()
}

/// Presenter -> Service
extension SingleSongPlayerPresenter {
    
}

/// Presenter -> Router
extension SingleSongPlayerPresenter {
    func navigateTo(destination: Destination, bundle: [String: Any]) {
        router?.navigateTo(destination: destination, bundle: bundle)
    }
}
