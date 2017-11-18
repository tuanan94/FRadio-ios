//
//  SongRequestingViewController.swift
//  SwiftRadio
//
//  Created by Tran Tuan An on 2017/11/12.
//  Copyright © 2017年 CodeMarket.io. All rights reserved.
//

import UIKit
import Alamofire
import NotificationBannerSwift
class SongRequestingViewController: UIViewController {
    let TARGET_URL = "http://fradio.site"
    var videoId: String!
    
    @IBOutlet weak var webview: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        let urlPath = Bundle.main.path(forResource: "request_waiting", ofType: "html")
        webview.loadRequest(URLRequest.init(url: URL(fileURLWithPath: urlPath!)))
        webview.scrollView.isScrollEnabled = false
        // Send request
        let parameters = ["id":videoId as String]
        Alamofire.request(TARGET_URL + "/api/create_song", method: .post , parameters: parameters).responseString { response in
            if (response.response?.statusCode != 200){
                self.performSegue(withIdentifier: "backtotop", sender: "fail")
                
            }else{
                self.performSegue(withIdentifier: "backtotop", sender: "success")
            }
        }
        
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NowPlayingViewController.notification = sender as! String
     }
    
}
