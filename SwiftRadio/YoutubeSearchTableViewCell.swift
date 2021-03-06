//
//  YoutubeSearchTableViewCell.swift
//  SwiftRadio
//
//  Created by Tran Tuan An on 2017/10/29.
//  Copyright © 2017 CodeMarket.io. All rights reserved.
//

import UIKit

class YoutubeSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var videoTitle: UILabel!
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
