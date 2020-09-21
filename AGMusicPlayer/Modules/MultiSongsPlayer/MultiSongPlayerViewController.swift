import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxGesture
import SDWebImage
import AVFoundation

class MultiSongPlayerViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionViewSongs: UICollectionView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songSubtitleLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var songCompletedTimeLabel: UILabel!
    @IBOutlet weak var songTotalTimeLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var presenter: MultiSongPlayerPresenter?
    var bundle: [String: Any] = [:]
    var delegate: ViewControllerResultDelegate?
    private var disposeBag = DisposeBag()
    fileprivate var isLoading = BehaviorRelay(value: false)
    fileprivate var query = "charlie puth"
    
    fileprivate var cellCurrentIndex = 0
    internal var arrSongs: [ResultData] = []
    fileprivate var audioManager = AudioManager.shared
    fileprivate var isTapOnPlay = false
    fileprivate var timer: Timer? = nil {
        willSet {
            self.timer?.invalidate()
        }
    }
    
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
        
        self.slider.value = 0
        self.songCompletedTimeLabel.text = "00:00"
        self.songTotalTimeLabel.text = "00:00"
        
        self.baseView.isHidden = true
        self.isLoading.accept(true)
        let param = self.presenter?.getSearchParam(searchQuery: self.query)
        self.presenter?.searchByQuery(parameters: param!)
    }
    
    // Function to set up collection view...
    func initCollectionView() {
        self.collectionViewSongs.delegate = self
        self.collectionViewSongs.dataSource = self
        self.collectionViewSongs.register(UINib(nibName: "SongCoverPhotoCVCell", bundle: nil), forCellWithReuseIdentifier: "SongCoverPhotoCVCell")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        
        self.backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        self.previousButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if ((self?.cellCurrentIndex ?? 0) != 0) && ((self?.cellCurrentIndex ?? 0) - 1) < ((self?.arrSongs.count ?? 0) - 1) {
                    self?.cellCurrentIndex -= 1
                    self?.setUpPlayer()
                    self?.scrollTheCollectionView()
                    self?.setUpSongData()
                }
            })
            .disposed(by: self.disposeBag)
        
        self.nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if ((self?.arrSongs.count ?? 0) > 0) && ((self?.cellCurrentIndex ?? 0) + 1) < (self?.arrSongs.count ?? 0) {
                    self?.cellCurrentIndex += 1
                    self?.setUpPlayer()
                    self?.scrollTheCollectionView()
                    self?.setUpSongData()
                }
            })
            .disposed(by: self.disposeBag)
        
        self.playPauseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if self?.isTapOnPlay == false {
                    self?.playAudio()
                } else {
                    self?.pauseAudio()
                }
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
                    }
                } else if gesture.direction == UISwipeGestureRecognizer.Direction.right {
                    if self.cellCurrentIndex != 0 && self.cellCurrentIndex - 1 < self.arrSongs.count - 1 {
                        self.cellCurrentIndex -= 1
                    }
                }
                self.setUpSongData()
                self.setUpPlayer()
                self.scrollTheCollectionView()
            })
            .disposed(by: disposeBag)
    }
    
    //    // do backward the audio with 5 sec...
    //    @IBAction func previousAction(_ sender: UIButton) {
    //        var currentTime = (self.audioManager.audioPlayer.currentTime - 5.0)
    //        if currentTime < 0 {
    //            currentTime = 0
    //            self.songCompletedTimeLabel.text = self.getTime(time: currentTime)
    //            self.audioManager.audioPlayer.currentTime = TimeInterval(currentTime)
    //            self.slider.value = Float(currentTime)
    //        } else {
    //            self.songCompletedTimeLabel.text = self.getTime(time: currentTime)
    //            self.audioManager.audioPlayer.currentTime = TimeInterval(currentTime)
    //            self.slider.value = Float(currentTime)
    //        }
    //    }
    //
    //    // Fast forward audio with 5 sec...
    //    @IBAction func nextAction(_ sender: UIButton) {
    //        let currentTime = (self.audioManager.audioPlayer.currentTime + 5.0)
    //        let totalTime = self.audioManager.audioPlayer.duration
    //        if currentTime > totalTime {
    //            self.songCompletedTimeLabel.text = self.getTime(time: totalTime)
    //            self.audioManager.audioPlayer.currentTime = TimeInterval(totalTime)
    //            self.slider.value = Float(totalTime)
    //        } else {
    //            self.songCompletedTimeLabel.text = self.getTime(time: currentTime)
    //            self.audioManager.audioPlayer.currentTime = TimeInterval(currentTime)
    //            self.slider.value = Float(currentTime)
    //        }
    //    }
    
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
    
    @IBAction func sliderAction(_ sender: UISlider) {
        self.audioManager.audioPlayer.currentTime = TimeInterval(slider.value)
        self.playAudio()
    }
    
    func setUpSongData() {
        self.songTitleLabel.text = self.arrSongs[cellCurrentIndex].trackName
        self.songSubtitleLabel.text = self.arrSongs[cellCurrentIndex].artistName
    }
    
    deinit {
        self.audioManager.stopAudio()
    }
}

extension MultiSongPlayerViewController {
    
    func searchByQuerySuccessWithResponse(response: Any) {
        isLoading.accept(false)
        if let apiResponse = response as? SongsResponse {
            self.baseView.isHidden = false
            self.arrSongs.removeAll()
            self.arrSongs = apiResponse.results ?? []
            self.setUpPlayer()
            self.setUpSongData()
            self.collectionViewSongs.reloadData()
        } else if let apiResponse = response as? ErrorResponse {
            let msg = apiResponse.error?.message ?? ""
            AppDelegate.showToast(message: msg)
        }
    }
    
    func searchByQueryFailureWithError(error: Error) {
        isLoading.accept(false)
        AppDelegate.showToast(message: error.localizedDescription)
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
        
        cell.cardViewLeadingConstraint.constant = 9
        cell.cardViewTrailingConstraint.constant = 9
        
        if indexPath.row == 0 {
            cell.cardViewLeadingConstraint.constant = 30
        } else if indexPath.row == (self.arrSongs.count - 1) {
            cell.cardViewTrailingConstraint.constant = 30
        }
        
        return cell
    }
}

extension MultiSongPlayerViewController: CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath: IndexPath) -> CGSize {
        var itemWidth = UIScreen.main.bounds.width - 60
        if sizeForItemAtIndexPath.row == 0 || sizeForItemAtIndexPath.row == (self.arrSongs.count - 1) {
            itemWidth = itemWidth + 30.0
        }
        return CGSize(width: itemWidth, height: collectionView.frame.height)
    }
}

extension MultiSongPlayerViewController: ViewControllerResultDelegate {
    func viewControllerResultBundle(bundle: [String : Any]) {
        
    }
}

// MARK :-  Functions related to audio player...
extension MultiSongPlayerViewController {
    
    // A function to set up the player, prepare to play initially...
    func setUpPlayer() {
        if let url = self.arrSongs[self.cellCurrentIndex].previewUrl {
            self.playPauseButton.alpha = 0
            self.activityIndicator.alpha = 1
            self.activityIndicator.startAnimating()
            self.audioManager.prepareToPlayAudio(audioUrl: url) { [weak self] (isDone) in
                if isDone {
                    // After prepare to play the audio, do some setup...
                    DispatchQueue.main.async {
                        self?.playPauseButton.alpha = 1
                        self?.activityIndicator.alpha = 0
                        self?.activityIndicator.stopAnimating()
                        self?.slider.value = 0
                        self?.songCompletedTimeLabel.text = "00:00"
                        self?.songTotalTimeLabel.text = self?.getTime(time: (self?.audioManager.audioPlayer.duration)!)
                        self?.slider.maximumValue = Float((self?.audioManager.audioPlayer.duration)!)
                        self?.playAudio()
                    }
                }
            }
        }
    }
    
    // A function to play the audio...
    func playAudio() {
        self.isTapOnPlay = true
        self.playPauseButton.setImage(UIImage(named: "ic_pause_white"), for: .normal)
        self.audioManager.playAudio()
        self.startProgressTimer()
    }
    
    // A function to pause the audio...
    func pauseAudio() {
        self.isTapOnPlay = false
        self.playPauseButton.setImage(UIImage(named: "ic_play_white"), for: .normal)
        self.audioManager.pauseAudio()
        self.stopProgressTimer()
    }
    
    // A function to reset the player...
    func resetPlayer() {
        self.isTapOnPlay = false
        self.audioManager.stopAudio()
        self.stopProgressTimer()
        self.setUpPlayer()
        DispatchQueue.main.async {
            self.playPauseButton.setImage(UIImage(named: "ic_play_white"), for: .normal)
            self.slider.value = 0
            self.songCompletedTimeLabel.text = "00:00"
        }
    }
    
    // A function to update the completed time label and progress bar...
    @objc func updateCurrentDuration() {
        let currentTime = (self.audioManager.audioPlayer.currentTime + 1.0)
        let totalTime = self.audioManager.audioPlayer.duration
        print("Current Time: ", self.getTime(time: currentTime))
        DispatchQueue.main.async {
            self.songCompletedTimeLabel.text = self.getTime(time: currentTime)
            self.slider.value = Float(currentTime)
        }
        if totalTime <= currentTime {
            if self.arrSongs.count > self.cellCurrentIndex {
                self.cellCurrentIndex += 1
                self.resetPlayer()
                self.scrollTheCollectionView()
                self.setUpSongData()
            }
        }
    }
    
    // A function to start timer progress...
    func startProgressTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentDuration), userInfo: nil, repeats: true)
    }
    
    // A function to stop timer prgress...
    func stopProgressTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

extension UIImage {
    func getThumbnail() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 300] as CFDictionary
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        return UIImage(cgImage: imageReference)
    }
}
