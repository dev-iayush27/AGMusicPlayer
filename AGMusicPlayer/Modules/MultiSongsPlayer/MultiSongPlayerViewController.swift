import Foundation
import UIKit
import RxCocoa
import RxSwift
import SDWebImage
import AVFoundation

class MultiSongPlayerViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var collectionViewSongs: UICollectionView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songSubtitleLabel: UILabel!
    @IBOutlet weak var songProgressBar: UISlider!
    @IBOutlet weak var songCompletedTimeLabel: UILabel!
    @IBOutlet weak var songTotalTimeLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var presenter: MultiSongPlayerPresenter?
    var bundle: [String: Any] = [:]
    var delegate: ViewControllerResultDelegate?
    private var disposeBag = DisposeBag()
    fileprivate var isLoading = BehaviorRelay(value: false)
    
    fileprivate var cellCurrentIndex = 0
    internal var arrSongs: [ResultData] = []
    fileprivate var isTapOnPlay = false
    fileprivate var player = AVQueuePlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let delegate = bundle[Constants.BundleConstants.delegate] as? ViewControllerResultDelegate {
            self.delegate = delegate
        }
        
        if let arrSongs = bundle[Constants.BundleConstants.resultData] as? [ResultData] {
            self.arrSongs = arrSongs
        }
        
        self.initSetUp()
    }
    
    func initSetUp() {
        self.initRxBindings()
        self.initCollectionView()
        self.setUpPlayer()
        self.initNavBar()
        self.configureNavigationBar()
    }
    
    func initNavBar() {
        self.title = "Multiple Song Player"
    }
    
    // Function to set up collection view...
    func initCollectionView() {
        self.collectionViewSongs.delegate = self
        self.collectionViewSongs.dataSource = self
        self.collectionViewSongs.register(UINib(nibName: "SongCoverPhotoCVCell", bundle: nil), forCellWithReuseIdentifier: "SongCoverPhotoCVCell")
        self.collectionViewSongs.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Function to configure navigation bar
    func configureNavigationBar() {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        initViews()
        initData()
    }
    
    /// Function to initialize view components
    private func initViews() {
    }
    
    /// Function to call data or perform navigation action on viewWillAppear
    private func initData() {
    }
    
    /// Function to initialize Rx for views and variables
    private func initRxBindings() {
        isLoading
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
                self?.play()
            })
            .disposed(by: self.disposeBag)
        
        self.nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if ((self?.arrSongs.count ?? 0) > 0) && ((self?.cellCurrentIndex ?? 0) + 1) < (self?.arrSongs.count ?? 0) {
                    self?.cellCurrentIndex += 1
                    self?.scrollTheCollectionView()
                }
                self?.setUpPlayer()
                self?.play()
            })
            .disposed(by: self.disposeBag)
        
        self.playPauseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.playAndPause()
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
                self.play()
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        self.pause()
    }
    
    func playAndPause() {
        self.isTapOnPlay = !self.isTapOnPlay
        if self.isTapOnPlay == true {
            self.play()
        } else {
            self.pause()
        }
    }
    
    func play() {
        self.isTapOnPlay = true
        self.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        self.playUrl()
    }
    
    func pause() {
        self.isTapOnPlay = false
        self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        self.player.pause()
    }
    
    func setUpPlayer() {
        self.songTitleLabel.text = self.arrSongs[cellCurrentIndex].trackName
        self.songSubtitleLabel.text = self.arrSongs[cellCurrentIndex].artistName
        self.songTotalTimeLabel.text = self.arrSongs[cellCurrentIndex].trackTimeMillis?.msToSeconds.minuteSecondMS
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
    
    func playUrl() {
        guard let previewUrl = self.arrSongs[self.cellCurrentIndex].previewUrl else {
            AppDelegate.showToast(message: "Preview URL not found.", isLong: true)
            self.pause()
            return
        }
        let url = URL(string: previewUrl)
        self.player.removeAllItems()
        self.player.insert(AVPlayerItem(url: url!), after: nil)
        self.player.play()
    }
}

extension MultiSongPlayerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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

extension MultiSongPlayerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.bounds.height)
    }
}

extension MultiSongPlayerViewController: ViewControllerResultDelegate {
    func viewControllerResultBundle(bundle: [String : Any]) {
        
    }
}

extension MultiSongPlayerViewController {
}
