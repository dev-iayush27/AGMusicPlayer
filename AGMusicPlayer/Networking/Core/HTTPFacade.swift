//
//  HTTPFacade.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 09/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class HTTPFacade<TypeOfTarget: NetworkTargetType> {
    
    private var provider: MoyaProvider<TypeOfTarget> = MoyaProviderFactory<TypeOfTarget>().moyaProvider()
    private var subject = PublishSubject<Data>()
    private var bag = DisposeBag()

    func request(target: TypeOfTarget) -> Single<Data> {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return Single.create { observer in
            self.provider.rx.request(target).subscribe { event in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                AppDelegate.finishLoading()
                switch event {
                case let .success(response):
                    observer(.success(response.data))
                case let .error(error):
                    if error.code == 401 {
                        NotificationCenter.default.post(name: Notification.Name("logoutUser"), object: nil)
                        return
                    } else {
                        observer(.error(checkFailureError(error)))
                    }
                }
            }.disposed(by: self.bag)

            return Disposables.create {}
        }
    }
}
