//
//  SingleSongPlayerVC.swift
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
import AVFoundation

class SingleSongPlayerVC: UIViewController {
    
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
    
    private var disposeBag = DisposeBag()
    fileprivate var isLoading = BehaviorRelay(value: false)
    internal var songData: ResultData?
    fileprivate var isTapOnPlay = false
    fileprivate var player = AVQueuePlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initRxBindings()
        self.initSetUpData()
        self.initNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.songCoverImage.layer.cornerRadius = 16
        self.songCoverImage.clipsToBounds = true
    }
    
    func initNavBar() {
        self.title = "Single Song Player"
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

extension TimeInterval {
    var minuteSecondMS: String {
        return String(format:"%d:%02d", minute, second)
    }
    var minute: Int {
        return Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
}

extension Int {
    var msToSeconds: Double {
        return Double(self) / 1000
    }
}
