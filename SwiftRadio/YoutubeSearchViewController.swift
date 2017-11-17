//
//  YoutubeSearchViewController.swift
//  SwiftRadio
//
//  Created by Tran Tuan An on 2017/10/29.
//  Copyright © 2017 CodeMarket.io. All rights reserved.
//

import UIKit

class YoutubeSearchViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchKeyword: UITextField!
    var dataSource: MyDataSource?
    var delegate: MyDataDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = MyDataSource()
        delegate = MyDataDelegate()
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.reloadData()
        YoutubeAPI.get_search(query: ""){ (result) -> () in
            self.reloadSearchTableView(result: result as! NSDictionary)
        }
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadSearchTableView(result: NSDictionary){
        dataSource?.setData(data: result)
        tableView.reloadData()
    }
    
    @IBAction func performSearch(_ sender: Any) {
        let keyword: String = searchKeyword.text!
        YoutubeAPI.get_search(query:keyword){ (result) -> () in
            self.reloadSearchTableView(result: result as! NSDictionary)
        }
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let row = tableView.indexPathForSelectedRow?.row
        let detailController = segue.destination as! YoutubeDetailViewController
        detailController.videoDetails = dataSource?.items.object(at: row!) as! NSDictionary
        print("go to details")
    }
    class MyDataSource: NSObject, UITableViewDataSource{
        var searchResult: NSDictionary!
        var items: NSArray!
        func setData(data: NSDictionary) -> Void {
            self.searchResult = data
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if (searchResult == nil){
                return 0
            }
            items = searchResult.object(forKey: "items") as! NSArray
            return items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Youtube-cell", for: indexPath) as! YoutubeSearchTableViewCell
            let item = items.object(at: indexPath.row) as! NSDictionary
            let snippet = item.object(forKey: "snippet") as! NSDictionary
            let title = snippet["title"] as! String
            let description = snippet["description"] as! String
            let thumnails = snippet.object(forKey: "thumbnails") as! NSDictionary
            let mediumThumbnail = thumnails.object(forKey: "medium") as! NSDictionary
            let mediumThumbnailURL = mediumThumbnail["url"] as! String
            cell.videoTitle.text = title
            cell.videoDescription.text = description
            cell.videoThumbnail.setImage(urlString: mediumThumbnailURL, contentMode: UIViewContentMode.scaleAspectFit, placeholderImage: nil)
            return cell
        }
    }
    
    class MyDataDelegate: NSObject, UITableViewDelegate{
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 200
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            
        }
    }

}
extension String {
    var forSorting: String {
        let simple = folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)
        let nonAlphaNumeric = CharacterSet.alphanumerics.inverted
        return simple.components(separatedBy: nonAlphaNumeric).joined(separator: "")
    }
}


