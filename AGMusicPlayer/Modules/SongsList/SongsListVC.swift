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
    
    @IBOutlet weak var tableViewSongs: UITableView!
    
    private var disposeBag = DisposeBag()
    fileprivate var isLoading = BehaviorRelay(value: false)
    fileprivate var arrSongs: [ResultData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initSetUp()
    }
    
    func initSetUp() {
        self.initNavBar()
        self.initRxBindings()
        self.initTableViewSetUp()
        self.getSongs()
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
        let vc = PlayerVC(nibName: "PlayerVC", bundle: nil)
        vc.arrSongs = self.arrSongs
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getUrl() -> String {
        let searchKeyword = "justin bieber"
        let searchString = searchKeyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let baseURL = "https://itunes.apple.com/search?" + "term=\(searchString!)&media=music&entity=musicTrack"
        print(baseURL)
        return baseURL
    }
    
    func getSongs() {
        self.isLoading.accept(true)
        APIManager.getData(url: self.getUrl(), success: { (response) in
            self.isLoading.accept(false)
            print(response)
            self.arrSongs = response.results ?? []
            self.tableViewSongs.reloadData()
        }) { (error) in
            print(error.localizedDescription)
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
        let vc = SingleSongPlayerVC(nibName: "SingleSongPlayerVC", bundle: nil)
        vc.songData = self.arrSongs[indexPath.item]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
