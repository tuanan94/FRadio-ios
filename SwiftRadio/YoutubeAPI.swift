//
//  YoutubeAPI.swift
//  SwiftRadio
//
//  Created by Tran Tuan An on 2017/10/29.
//  Copyright © 2017 CodeMarket.io. All rights reserved.
//

import Foundation
import Alamofire

class YoutubeAPI {
    static let YOUTUBE_API_KEY = "AIzaSyDZaBwBbLqgsNwGaFihdkuiyM3OHpVI64g"
    
    class func get_search(query: String, completion: @escaping (_ result: Any)->()){
        let queryAfterReplace = query.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        Alamofire.request("https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=25&q="+queryAfterReplace!+"&type=video&key=" + YOUTUBE_API_KEY).responseJSON { response in
            if let json = response.result.value {
                completion(json)
            }
        }
    }

}
