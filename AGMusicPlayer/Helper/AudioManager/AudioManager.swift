//
//  AudioManager.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 20/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import Foundation
import AVFoundation

class AudioManager: NSObject {
    
    static let shared = AudioManager()
    
    public override init(){}
    
    var audioPlayer = AVAudioPlayer()
    
    func prepareToPlayAudio(audioUrl: String, onSuccess: @escaping (Bool) -> ()) {
        self.downloadFileFromURL(audioUrl: URL(string: audioUrl)!, onSuccess: onSuccess)
    }
    
    func playAudio() {
        self.audioPlayer.play()
    }
    
    func pauseAudio() {
        self.audioPlayer.pause()
    }
    
    func stopAudio() {
        self.audioPlayer.stop()
    }
    
    func getTotalDuration() -> TimeInterval {
        return self.audioPlayer.duration
    }
    
    func downloadFileFromURL(audioUrl: URL, onSuccess: @escaping (Bool) -> ()) {
        var downloadTask: URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: audioUrl) { (url, response, error) in
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url! as URL)
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.volume = 1.0
                onSuccess(true)
            } catch let error as NSError {
                print(error.localizedDescription)
                onSuccess(false)
            } catch {
                print("AVAudioPlayer init failed")
                onSuccess(false)
            }
        }
        downloadTask.resume()
    }
}
