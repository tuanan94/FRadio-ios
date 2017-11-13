//
//  SongRequestingViewController.swift
//  SwiftRadio
//
//  Created by Tran Tuan An on 2017/11/12.
//  Copyright © 2017年 CodeMarket.io. All rights reserved.
//

import UIKit
import Alamofire

class SongRequestingViewController: UIViewController {
    let TARGET_URL = "http://fradio.site"
    var videoId: String!
    
    @IBOutlet weak var resultBtn: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("songrequestdidload")
        resultBtn.isHidden = true
        // Send request
        let parameters = ["id":videoId as String]
        Alamofire.request(TARGET_URL + ":3000/create_song", method: .post , parameters: parameters).responseString { response in
            debugPrint(response)
            let json = response.result.value
            print(json as Any)
            if (response.response?.statusCode != 200){
                self.resultBtn.backgroundColor = self.UIColorFromHex(rgbValue: 0xf99595)
                self.resultBtn.setTitle("Something went wrong.\n I will investigate this case asap", for: UIControlState.normal)
            }else{
                // Leave button as default
            }
            self.resultBtn.titleLabel!.lineBreakMode = .byWordWrapping
            self.resultBtn.titleLabel!.textAlignment = .center
            self.resultBtn.isHidden = false
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
