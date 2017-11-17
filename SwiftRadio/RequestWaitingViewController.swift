//
//  RequestWaitingViewController.swift
//  SwiftRadio
//
//  Created by Tran Tuan An on 2017/11/17.
//  Copyright © 2017年 CodeMarket.io. All rights reserved.
//

import UIKit
import WebKit

class RequestWaitingViewController: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlPath = Bundle.main.path(forResource: "request_waiting", ofType: "html")
        webview.loadRequest(URLRequest.init(url: URL(fileURLWithPath: urlPath!)))
        webview.scrollView.isScrollEnabled = false
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
