//
//  YoutubeDetailViewController.swift
//  SwiftRadio
//
//  Created by Tran Tuan An on 2017/10/29.
//  Copyright © 2017 CodeMarket.io. All rights reserved.
//

import UIKit

class YoutubeDetailViewController: UIViewController {
    var videoDetails: NSDictionary!
    
    @IBOutlet weak var videoImage: UIImageView!
    
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoDescription: UILabel!
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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
