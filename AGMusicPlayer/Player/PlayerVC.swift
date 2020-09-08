//
//  PlayerVC.swift
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

class PlayerVC: UIViewController {
    
    @IBOutlet weak var collectionViewSongs: UICollectionView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songSubtitleLabel: UILabel!
    @IBOutlet weak var songProgressBar: UISlider!
    @IBOutlet weak var songCompletedTimeLabel: UILabel!
    @IBOutlet weak var songTotalTimeLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    private var disposeBag = DisposeBag()
    fileprivate var isLoading = BehaviorRelay(value: false)
    fileprivate var cellCurrentIndex = 0
    fileprivate var arrSongs: [ResultData] = []
    fileprivate var isTapOnPlay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initRxBindings()
        self.initCollectionView()
        self.getSongs()
    }
    
    // Function to set up collection view...
    func initCollectionView() {
        self.collectionViewSongs.delegate = self
        self.collectionViewSongs.dataSource = self
        self.collectionViewSongs.register(UINib(nibName: "SongCoverPhotoCVCell", bundle: nil), forCellWithReuseIdentifier: "SongCoverPhotoCVCell")
    }
    
    // Function to initialize Rx for views and variables
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
        
        self.previousButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if ((self?.cellCurrentIndex ?? 0) != 0) && ((self?.cellCurrentIndex ?? 0) - 1) < ((self?.arrSongs.count ?? 0) - 1) {
                    self?.cellCurrentIndex -= 1
                    self?.scrollTheCollectionView()
                }
                self?.setUpPlayer()
            })
            .disposed(by: self.disposeBag)
        
        self.nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if ((self?.arrSongs.count ?? 0) > 0) && ((self?.cellCurrentIndex ?? 0) + 1) < (self?.arrSongs.count ?? 0) {
                    self?.cellCurrentIndex += 1
                    self?.scrollTheCollectionView()
                }
                self?.setUpPlayer()
            })
            .disposed(by: self.disposeBag)
        
        self.playPauseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.isTapOnPlay = !(self?.isTapOnPlay ?? false)
                self?.playPauseButton.setImage(self?.isTapOnPlay == true ? UIImage(named: "pause") : UIImage(named: "play"), for: .normal)
            })
            .disposed(by: self.disposeBag)
        
        // collection view swipe gesture left to right and right to left...
        self.collectionViewSongs.rx
            .swipeGesture([.left, .right])
            .when(.recognized)
            .subscribe(onNext: { gesture in
                if gesture.direction == UISwipeGestureRecognizer.Direction.left {
                    if self.arrSongs.count > 0 && self.cellCurrentIndex + 1 < self.arrSongs.count {
                        self.cellCurrentIndex += 1
                        self.scrollTheCollectionView()
                    }
                } else if gesture.direction == UISwipeGestureRecognizer.Direction.right {
                    if self.cellCurrentIndex != 0 && self.cellCurrentIndex - 1 < self.arrSongs.count - 1 {
                        self.cellCurrentIndex -= 1
                        self.scrollTheCollectionView()
                    }
                }
                self.setUpPlayer()
            })
            .disposed(by: disposeBag)
    }
    
    func setUpPlayer() {
        self.songTitleLabel.text = self.arrSongs[cellCurrentIndex].trackName
        self.songSubtitleLabel.text = self.arrSongs[cellCurrentIndex].artistName
    }
    
    // Function to handle scroll collectionview...
    func scrollTheCollectionView() {
        UIView.animate(withDuration: 2.0, animations: {
            if self.cellCurrentIndex < self.arrSongs.count {
                self.collectionViewSongs.reloadData()
                let indePath = IndexPath(item: self.cellCurrentIndex, section: 0)
                self.collectionViewSongs.scrollToItem(at: indePath, at: .centeredHorizontally, animated: true)
            }
        })
    }
    
    func getSongs() {
        
        self.isLoading.accept(true)
        APIManager.getData(url: self.getUrl(), success: { (response) in
            self.isLoading.accept(false)
            print(response)
            self.arrSongs = response.results
            self.setUpPlayer()
            self.collectionViewSongs.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getUrl() -> String {
        let searchKeyword = "Shape of you"
        let searchString = searchKeyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let baseURL = "https://itunes.apple.com/search?" + "term=\(searchString!)&media=music&entity=musicTrack"
        print(baseURL)
        return baseURL
    }
}

extension PlayerVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.arrSongs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongCoverPhotoCVCell", for: indexPath) as! SongCoverPhotoCVCell
        if let coverImage = self.arrSongs[indexPath.item].artworkUrl100 {
            cell.songCoverImage.sd_setImage(with: URL(string: coverImage), placeholderImage: nil, options:.refreshCached)
        }
        return cell
    }
}

extension PlayerVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.bounds.height)
    }
}
