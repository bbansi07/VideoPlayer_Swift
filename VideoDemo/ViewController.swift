//
//  ViewController.swift
//  VideoDemo
//
//  Created by Bansi Bhatt on 15/03/17.
//  Copyright © 2017 Bansi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var viewPlayer : UIView!
    @IBOutlet weak var slider : UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblTime : UILabel!
    
    var playerRateBeforeSeek: Float = 0
    var player : AVPlayer? = nil
    var playerLayer : AVPlayerLayer? = nil
    var asset : AVAsset? = nil
    var playerItem: AVPlayerItem? = nil
    private var playback = 0
    
    let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    lazy var cameraSession: AVCaptureSession = {
        let s = AVCaptureSession()
        s.sessionPreset = AVCaptureSessionPresetLow
        return s
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview?.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        preview?.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        preview?.videoGravity = AVLayerVideoGravityResize
        return preview!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        slider!.minimumValue = 0.0
        
        slider!.addTarget(self, action: #selector(sliderBeganTracking),
                         for: .touchDown)
        slider.addTarget(self, action: #selector(sliderEndedTracking),
                         for: [.touchUpInside, .touchUpOutside])
        
        slider.addTarget(self, action: #selector(sliderValueChanged),
                         for: .valueChanged)
        
        loadingIndicatorView.hidesWhenStopped = true
       
        viewPlayer.addSubview(loadingIndicatorView)
        player?.addObserver(self, forKeyPath:"currentItem.playbackLikelyToKeepUp",
                             options: .new, context: &playback)
        setupCameraSession()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func captureVideo(){
        setupCameraSession()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            /*let duration = player?.currentItem?.duration
            let seconds : Float64 = CMTimeGetSeconds(duration!)
            
            lblTime.text = String(format: "%02d:%02d", ((lround(seconds) / 60) % 60), lround(seconds) % 60)
       */
      //  let timeRemaining: Float64! = CMTimeGetSeconds((player?.currentItem?.duration)!)
      //  lblTime.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
        //while capturing video
        
        view.layer.addSublayer(previewLayer)
        cameraSession.startRunning()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playVideo(_ sender: UIButton) {
       
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
        
        view.layer.insertSublayer(playerLayer!, at: 1)
        
       
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
       func setupCameraSession() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) //as AVCaptureDevice
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession.beginConfiguration()
            
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }
            
            cameraSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.invasivecode.videoQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        }
        catch let error as NSError {
            NSLog("error while capturing \(error), \(error.localizedDescription)")
        }
    }

    @IBAction func sliderValueChange(_ sender: UISlider) {
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &playback{
            if (player?.currentItem?.isPlaybackLikelyToKeepUp)!{
                loadingIndicatorView.stopAnimating()
            }else{
                loadingIndicatorView.startAnimating()
            }
        }
    }
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you collect each frame and process it
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you can count how many frames are dopped
    }
    deinit {
      
        player?.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
    }
}

