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
    var dataSource: MyDataSource?
    var delegate: MyDataDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = MyDataSource()
        delegate = MyDataDelegate()
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.reloadData()
        super.viewDidLoad()
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

class MyDataSource: NSObject, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Youtube-cell", for: indexPath) as! YoutubeSearchTableViewCell
        return cell
    }
}

class MyDataDelegate: NSObject, UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

