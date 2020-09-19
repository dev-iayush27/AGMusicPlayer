import Foundation
import RxCocoa
import RxSwift
import UIKit

class MultiSongPlayerPresenter {
    weak var viewController: MultiSongPlayerViewController?
    var router: MultiSongPlayerRouter?
    var service: MultiSongPlayerService?
    private var disposeBag = DisposeBag()
}

/// Presenter -> Service
extension MultiSongPlayerPresenter {
    
}

/// Presenter -> Router
extension MultiSongPlayerPresenter {
    func navigateTo(destination: Destination, bundle: [String: Any]) {
        router?.navigateTo(destination: destination, bundle: bundle)
    }
}
