//
//  YoutubeDetailViewController.swift
//  SwiftRadio
//
//  Created by Tran Tuan An on 2017/10/29.
//  Copyright © 2017 CodeMarket.io. All rights reserved.
//

import UIKit
import Alamofire

class YoutubeDetailViewController: UIViewController {
    var videoDetails: NSDictionary!
    
    @IBOutlet weak var videoImage: UIImageView!
    
    @IBOutlet weak var btnPushSong: UIButton!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoDescription: UILabel!
    var timer:Timer!
    var pressCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let snippet = videoDetails.object(forKey: "snippet") as! NSDictionary
        let title = snippet["title"] as! String
        let description = snippet["description"] as! String
        let thumnails = snippet.object(forKey: "thumbnails") as! NSDictionary
        let highThumbnail = thumnails.object(forKey: "high") as! NSDictionary
        let highThumbnailURL = highThumbnail["url"] as! String
        videoImage.setImage(urlString: highThumbnailURL, contentMode: UIViewContentMode.scaleAspectFit, placeholderImage: nil)
        videoTitle.text = title
        videoDescription.text = description
        btnPushSong.layer.cornerRadius = 10;
        btnPushSong.clipsToBounds = true;
        self.title = title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnTouchDown(_ sender: Any) {
        print("start")
        timer = Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(self.rapidFire),
                             userInfo: nil,
                             repeats: true)
        pressCount = 0;
        btnPushSong.setTitle("\(pressCount)" + "...", for: UIControlState.normal)
    }
    
    @objc func rapidFire() {
        if (pressCount == 3) {
            performSegue(withIdentifier: "goToSongRequesting", sender: nil)
            timer.invalidate()
            btnPushSong.setTitle("Hold me to push this article", for: UIControlState.normal)
        }
        self.pressCount+=1;
        btnPushSong.setTitle("\(pressCount)" + "...", for: UIControlState.normal)
        print("bang")
    }
    
    @IBAction func btnTouchUp(_ sender: Any) {
        print("stop")
        timer.invalidate()
        btnPushSong.setTitle("Hold me to push this article", for: UIControlState.normal)
    }
    
    /*
     MARK: - Navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let id = videoDetails.object(forKey: "id") as! NSDictionary
        let videoId = id["videoId"] as! String
        var songRequestingController = segue.destination as! SongRequestingViewController
        songRequestingController.videoId = videoId
        print("go to request controller")
    }

}
