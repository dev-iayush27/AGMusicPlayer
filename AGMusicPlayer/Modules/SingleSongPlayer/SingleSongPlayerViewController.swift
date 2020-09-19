import UIKit
import RxCocoa
import RxSwift
import RxGesture
import SDWebImage

class SingleSongPlayerViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var songCoverImage: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songSubtitleLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
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
    fileprivate var audioManager = AudioManager.shared
    
    internal var songData: ResultData?
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
        
        if let songData = bundle[Constants.BundleConstants.songData] as? ResultData {
            self.songData = songData
        }
        
        self.initSetUp()
    }
    
    func initSetUp() {
        self.initRxBindings()
        self.configureNavigationBar()
        self.initSetUpData()
        self.setUpPlayer()
        self.title = "Single Song Player"
        self.progressBar.progress = 0.0
        self.songCompletedTimeLabel.text = "00:00"
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
                if self?.isTapOnPlay == false {
                    self?.playAudio()
                } else {
                    self?.pauseAudio()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func initSetUpData() {
        if let coverImage = self.songData?.artworkUrl100 {
            self.songCoverImage.sd_setImage(with: URL(string: coverImage), placeholderImage: nil, options:.refreshCached)
        }
        self.songTitleLabel.text = self.songData?.trackName ?? ""
        self.songSubtitleLabel.text = self.songData?.artistName ?? ""
        self.songTotalTimeLabel.text = "00:00"
    }
    
    deinit {
        self.audioManager.stopAudio()
    }
}

extension SingleSongPlayerViewController: ViewControllerResultDelegate {
    func viewControllerResultBundle(bundle: [String : Any]) {
        
    }
}

// MARK :-  Functions related to audio player...
extension SingleSongPlayerViewController {
    
    // A function to set up the player, prepare to play initially...
    func setUpPlayer() {
        if let url = self.songData?.previewUrl {
            self.playPauseButton.isEnabled = false
            self.audioManager.prepareToPlayAudio(audioUrl: url) { (isDone) in
                if isDone {
                    // After prepare to play the audio, do some setup...
                    DispatchQueue.main.async {
                        self.playPauseButton.isEnabled = true
                        self.songTotalTimeLabel.text = self.getTime(time: self.audioManager.getTotalDuration())
                    }
                }
            }
        }
    }
    
    // A function to play the audio...
    func playAudio() {
        self.isTapOnPlay = true
        self.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        self.startProgressTimer()
        self.audioManager.playAudio()
    }
    
    // A function to pause the audio...
    func pauseAudio() {
        self.isTapOnPlay = false
        self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        self.stopProgressTimer()
        self.audioManager.pauseAudio()
    }
    
    // A function to reset the player...
    func resetPlayer() {
        self.isTapOnPlay = false
        self.stopProgressTimer()
        self.audioManager.stopAudio()
        self.setUpPlayer()
        DispatchQueue.main.async {
            self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            self.progressBar.progress = 0.0
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
            self.progressBar.progress = Float(currentTime/totalTime)
        }
        if totalTime <= currentTime {
            self.resetPlayer()
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
