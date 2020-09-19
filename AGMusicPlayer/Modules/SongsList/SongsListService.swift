import RxSwift

class SongsListService {
    private let facade = HTTPFacade<NetworkTarget>()
    private let disposeBag = DisposeBag()
}

extension SongsListService {
 
    func searchByQuery(parameters: [String: Any]) -> Single<Data> {
        return Single.create { observer in
            let target = NetworkTarget.searchByQuery(parameters: parameters)
            self.facade.request(target: target).subscribe(onSuccess: { data in
                observer(.success(data))
            }, onError: { error in
                observer(.error(error))
            }).disposed(by: self.disposeBag)
            
            return Disposables.create {}
        }
    }
}
