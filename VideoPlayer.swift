//
//  VideoPlayer.swift
//  VideoDemo
//
//  Created by Bansi Bhatt on 17/03/17.
//  Copyright © 2017 Bansi. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer

class VideoPlayer: NSObject {
    
     weak var viewPlayer : UIView!
     weak var slider : UISlider!
     weak var btnPlay: UIButton!
     weak var lblTime : UILabel!
    
    var playerRateBeforeSeek: Float = 0
    var player : AVPlayer? = nil
    var playerLayer : AVPlayerLayer? = nil
    var asset : AVAsset? = nil
    var playerItem: AVPlayerItem? = nil
    private var playback = 0
    
    let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    func loadPage(){
        slider.minimumValue = 0.0
        
        slider.addTarget(self, action: #selector(sliderBeganTracking),
                         for: .touchDown)
        slider.addTarget(self, action: #selector(sliderEndedTracking),
                         for: [.touchUpInside, .touchUpOutside])
        
        slider.addTarget(self, action: #selector(sliderValueChanged),
                         for: .valueChanged)
        
        loadingIndicatorView.hidesWhenStopped = true
        
        viewPlayer.addSubview(loadingIndicatorView)
        player?.addObserver(self, forKeyPath:"currentItem.playbackLikelyToKeepUp",
                            options: .new, context: &playback)
        btnPlay.addTarget(self, action: #selector(playVideo(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderValueChange(_:)), for: .valueChanged)

    }
    func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = (player?.rate)!
        player?.pause()
    }
    
    func sliderEndedTracking(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds((player?.currentItem!.duration)!)
        let elapsedTime: Float64 = videoDuration * Float64(slider.value)
        //updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        player?.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100), completionHandler:{ (completed: Bool) -> Void in
            if self.playerRateBeforeSeek > 0 {
                self.player?.play()
            }
        })
    }
    
    func sliderValueChanged(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds((player?.currentItem!.duration)!)
        let elapsedTime: Float64 = videoDuration * Float64(slider.value)
        //  lblTime.text = "\(elapsedTime)"
        lblTime.text = String(format: "%02d:%02d", ((lround(elapsedTime) / 60) % 60), lround(elapsedTime) % 60)
        // updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }

    func playVideo(_ sender: UIButton) {
        
        let videoURLWithPath = "https://rmpsite-1479.kxcdn.com/media/bbb-360p.mp4"
        //"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"
        let videoURL = NSURL(string: videoURLWithPath)
        
        asset = AVAsset.init(url: videoURL as! URL)
        let duration = asset?.duration
        let seconds : Float = Float(CMTimeGetSeconds(duration!))
        
        slider.maximumValue = seconds
        
        playerItem = AVPlayerItem(asset: asset!)
        
        player = AVPlayer(playerItem: self.playerItem)
        
        playerLayer = AVPlayerLayer(player: self.player)
        playerLayer!.frame = self.viewPlayer.frame
        
       
        UIView().layer.insertSublayer(playerLayer!, at: 1)
        
        
        // self.view.layer.addSublayer(playerLayer!)
        
        // .addSublayer(self.playerLayer!)
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider(_:)), userInfo: nil, repeats: true)
        
        player!.play()
        
        print(player?.rate ?? "")
        
        /*let playerIsPlaying = Float((player?.rate)!) > 0.0
         if playerIsPlaying {
         player?.pause()
         } else {
         player?.play()
         }
         */
    }
    func sliderValueChange(_ sender: UISlider) {
        player?.pause()
        let time = CMTimeMake(Int64(slider.value), 1)
        player?.seek(to: time)
        player?.play()
    }
    
    func updateSlider(_ time : Timer){
        let duration = player?.currentTime()
        let seconds : Float = Float(CMTimeGetSeconds(duration!))
        slider.value = seconds
        lblTime.text = String(format: "%02d:%02d", ((lround(Double(seconds)) / 60) % 60), lround(Double(seconds)) % 60)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &playback{
            if (player?.currentItem?.isPlaybackLikelyToKeepUp)!{
                loadingIndicatorView.stopAnimating()
            }else{
                loadingIndicatorView.startAnimating()
            }
        }
    }
    deinit {
        
        player?.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
    }

}

