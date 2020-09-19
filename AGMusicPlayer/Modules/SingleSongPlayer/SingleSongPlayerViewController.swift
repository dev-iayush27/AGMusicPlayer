import UIKit
import RxCocoa
import RxSwift
import RxGesture
import SDWebImage
import AVFoundation

class SingleSongPlayerViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var songCoverImage: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songSubtitleLabel: UILabel!
    @IBOutlet weak var songProgressBar: UISlider!
    @IBOutlet weak var songCompletedTimeLabel: UILabel!
    @IBOutlet weak var songTotalTimeLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    var presenter: SingleSongPlayerPresenter?
    var bundle: [String: Any] = [:]
    var delegate: ViewControllerResultDelegate?
    private var disposeBag = DisposeBag()
    fileprivate var isLoading = BehaviorRelay(value: false)
    
    internal var songData: ResultData?
    fileprivate var isTapOnPlay = false
    fileprivate var player = AVQueuePlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let delegate = bundle[Constants.BundleConstants.delegate] as? ViewControllerResultDelegate {
            self.delegate = delegate
        }
        
        if let songData = bundle[Constants.BundleConstants.songData] as? ResultData {
            self.songData = songData
        }
        
        self.initSetUp()
    }
    
    func initSetUp() {
        self.initRxBindings()
        self.configureNavigationBar()
        self.initNavBar()
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
        self.songCoverImage.layer.cornerRadius = 16
        self.songCoverImage.clipsToBounds = true
    }
    
    /// Function to call data or perform navigation action on viewWillAppear
    private func initData() {
        self.initSetUpData()
    }
    
    func initNavBar() {
        self.title = "Single Song Player"
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
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: self.disposeBag)
        
        self.nextButton.rx.tap
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: self.disposeBag)
        
        self.playPauseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.isTapOnPlay = !(self?.isTapOnPlay ?? false)
                if self?.isTapOnPlay == true {
                    self?.play()
                } else {
                    self?.pause()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func play() {
        self.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        self.playUrl()
    }
    
    func pause() {
        self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        self.player.pause()
    }
    
    func initSetUpData() {
        if let coverImage = self.songData?.artworkUrl100 {
            self.songCoverImage.sd_setImage(with: URL(string: coverImage), placeholderImage: nil, options:.refreshCached)
        }
        self.songTitleLabel.text = self.songData?.trackName ?? ""
        self.songSubtitleLabel.text = self.songData?.artistName ?? ""
        self.songTotalTimeLabel.text = self.songData?.trackTimeMillis?.msToSeconds.minuteSecondMS
    }
    
    func playUrl() {
        guard let previewUrl = self.songData?.previewUrl else {
            AppDelegate.showToast(message: "Preview URL not found.", isLong: true)
            self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            self.player.pause()
            return
        }
        let url = URL(string: previewUrl)
        self.player.removeAllItems()
        self.player.insert(AVPlayerItem(url: url!), after: nil)
        self.player.play()
    }
    
    deinit {
        self.pause()
    }
}

extension SingleSongPlayerViewController: ViewControllerResultDelegate {
    func viewControllerResultBundle(bundle: [String : Any]) {
        
    }
}

extension SingleSongPlayerViewController {
}
