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
    func searchByQuery(parameters: [String: Any]) {
        service?.searchByQuery(parameters: parameters).subscribe(onSuccess: { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                if let JSON: NSDictionary = json as? NSDictionary {
                    if JSON.object(forKey: "error") != nil {
                        let response = ErrorResponse.from(JSON)!
                        self.viewController?.searchByQuerySuccessWithResponse(response: response)
                    } else {
                        let response = SongsResponse.from(JSON)!
                        self.viewController?.searchByQuerySuccessWithResponse(response: response)
                    }
                }
            } catch {}
        }, onError: { error in
            self.viewController?.searchByQueryFailureWithError(error: error)
        }).disposed(by: disposeBag)
    }
}

/// Presenter -> Router
extension MultiSongPlayerPresenter {
    func navigateTo(destination: Destination, bundle: [String: Any]) {
        router?.navigateTo(destination: destination, bundle: bundle)
    }
}

// Request Parameters
extension MultiSongPlayerPresenter {
    func getSearchParam(searchQuery: String) -> [String: Any] {
        let param = [
            Constants.ApiConstants.term: searchQuery,
            Constants.ApiConstants.media: "music",
            Constants.ApiConstants.entity: "musicTrack"
        ]
        return param
    }
}
