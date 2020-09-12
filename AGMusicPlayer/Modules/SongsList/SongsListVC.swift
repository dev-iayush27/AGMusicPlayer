//
//  SongsListVC.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 09/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import SDWebImage

class SongsListVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewSongs: UITableView!
    
    private var disposeBag = DisposeBag()
    internal var bundle: [String: Any] = [:]
    fileprivate var isLoading = BehaviorRelay(value: false)
    fileprivate var arrSongs: [ResultData] = []
    var navigator: SongsListNavigator?
    var service: SongsListService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSetUp()
    }
    
    func initSetUp() {
        self.initNavBar()
        self.initRxBindings()
        self.initTableViewSetUp()
        self.searchBar.delegate = self
    }
    
    func initNavBar() {
        self.title = "Songs"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "song"), style: .plain, target: self, action: #selector(self.handleSongs))
    }
    
    func initTableViewSetUp() {
        self.tableViewSongs.delegate = self
        self.tableViewSongs.dataSource = self
        self.tableViewSongs.register(UINib(nibName: "SongsTVCell", bundle: nil), forCellReuseIdentifier: "SongsTVCell")
    }
    
    func initRxBindings() {
        self.isLoading
            .asObservable()
            .bind { status in
                if status {
                    AppDelegate.startLoading()
                } else {
                    AppDelegate.finishLoading()
                }
        }
        .disposed(by: disposeBag)
    }
    
    @objc private func handleSongs() {
        let bundle = [
            Constants.BundleConstants.resultData: self.arrSongs
        ]
        self.navigator?.navigateTo(destination: Destination.multiSongPlayer, bundle: bundle)
    }
    
    func getSongsData() {
        let parameters: [String: Any] = [
            Constants.ApiConstants.term: self.searchBar.text ?? "",
            Constants.ApiConstants.media: "music",
            Constants.ApiConstants.entity: "musicTrack"
        ]
        self.isLoading.accept(true)
        let target = APIManagerTarget.searchAPI(parameters: parameters)
        APIManager.request(target: target, responseType: SongResults.self, onSuccess: { (result) in
            self.isLoading.accept(false)
            self.arrSongs.removeAll()
            self.arrSongs = result?.results ?? []
            self.tableViewSongs.reloadData()
            self.saveSearchListIntoAPICache(apiResponse: result!, query: self.searchBar.text ?? "")
        }) { (err) in
            self.isLoading.accept(false)
            print(err)
            AppDelegate.showToast(message: "Something went wrong.")
        }
    }
    
    func saveSearchListIntoAPICache(apiResponse: SongResults, query: String) {
        let modifiedQuery = query.replacingOccurrences(of: " ", with: Constants.CommonConstants.whiteSpaceAlternative)
        let responseName = "SearchList_\(modifiedQuery).json"
        APICacheManager.saveApiCacheResponse(responseName: responseName, responseType: SongResults.self, apiResponse: apiResponse)
    }
    
    func getSavedSearchListFromAPICache(query: String) {
        let modifiedQuery = query.replacingOccurrences(of: " ", with: Constants.CommonConstants.whiteSpaceAlternative)
        let responseName = "SearchList_\(modifiedQuery).json"
        APICacheManager.checkApiCacheAvailable(responseName: responseName, responseType: SongResults.self) { (status, response) in
            if (status && response?.results != nil) {
                self.arrSongs.removeAll()
                self.arrSongs = response?.results ?? []
                self.tableViewSongs.reloadData()
            } else {
                self.getSongsData()
            }
        }
    }
}

extension SongsListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTVCell", for: indexPath) as! SongsTVCell
        if let coverImage = self.arrSongs[indexPath.item].artworkUrl100 {
            cell.songCoverImage.sd_setImage(with: URL(string: coverImage), placeholderImage: nil, options:.refreshCached)
        }
        cell.songTitleLabel.text = self.arrSongs[indexPath.item].trackName ?? ""
        cell.songSubTitleLabel.text = self.arrSongs[indexPath.item].artistName ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bundle = [
            Constants.BundleConstants.songData: self.arrSongs[indexPath.item]
        ]
        self.navigator?.navigateTo(destination: Destination.singleSongPlayer, bundle: bundle)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension SongsListVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        self.getSavedSearchListFromAPICache(query: self.searchBar.text ?? "")
    }
}
