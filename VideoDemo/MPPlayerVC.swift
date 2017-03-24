//
//  MPPlayerVC.swift
//  AudioDemo
//
//  Created by Bansi Bhatt on 16/03/17.
//  Copyright © 2017 Bansi. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import MobileCoreServices

class MPPlayerVC: UIViewController {
    
    var moviePlayer : MPMoviePlayerViewController?
  
    @IBOutlet weak var vieww : UIView!
    
    override func viewDidLoad() {
      super.viewDidLoad()
        playVideo()
    }
    
     func playVideo(){
        
       // let path = Bundle.main.path(forResource: "ra3", ofType:"mp4")
       // let url = NSURL.fileURL(withPath: path!)
        
       // let videoURL = url
       
       
        let videoURLWithPath = "https://rmpsite-1479.kxcdn.com/media/bbb-360p.mp4"
      
        let videoURL = NSURL(string: videoURLWithPath)
        
        
        moviePlayer = MPMoviePlayerViewController(contentURL:  videoURL as! URL)
     
        if let player = moviePlayer {
            player.view.frame
                = CGRect(x: 5, y: 5, width: 200, height: 80)
            player.view.backgroundColor = UIColor.red
           
           // self.present(moviePlayer!, animated: true, completion: nil)
        }
        else {
            NSLog("no player")
        }
    }
    
    func showVideo(){
        
    /*    // Video file
        let videoFile = Bundle.main.path(forResource: "trailer_720p", ofType: "mov")
        
        // Subtitle file
        let subtitleFile = Bundle.main.path(forResource: "trailer_720p", ofType: "srt")
        let subtitleURL = URL(fileURLWithPath: subtitleFile!)
        
        // Movie player
        let moviePlayerView = MPMoviePlayerViewController(contentURL: URL(fileURLWithPath: videoFile!))
        presentMoviePlayerViewControllerAnimated(moviePlayerView)
        
        // Add subtitles
        moviePlayerView?.moviePlayer.addSubtitles().open(file: subtitleURL)
        moviePlayerView?.moviePlayer.addSubtitles().open(file: subtitleURL, encoding: String.Encoding.utf8)
        
        // Change text properties
        moviePlayerView?.moviePlayer.subtitleLabel?.textColor = UIColor.red
        
        // Play
        moviePlayerView?.moviePlayer.play()
 */
    }
}
