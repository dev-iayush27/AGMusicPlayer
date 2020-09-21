import Foundation
import RxCocoa
import RxSwift
import UIKit

class SplashPresenter {
    weak var viewController: SplashViewController?
    var router: SplashRouter?
    var service: SplashService?
    private var disposeBag = DisposeBag()
}

/// Presenter -> Service
extension SplashPresenter {
    
}

/// Presenter -> Router
extension SplashPresenter {
    func navigateTo(destination: Destination, bundle: [String: Any], type: Int) {
        router?.navigateTo(destination: destination, bundle: bundle, type: type)
    }
}
