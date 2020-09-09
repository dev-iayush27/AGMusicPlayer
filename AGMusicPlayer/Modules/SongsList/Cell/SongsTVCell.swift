//
//  SongsTVCell.swift
//  AGMusicPlayer
//
//  Created by Ayush Gupta on 09/09/20.
//  Copyright © 2020 Ayush Gupta. All rights reserved.
//

import UIKit

class SongsTVCell: UITableViewCell {
    
    @IBOutlet weak var songCoverImage: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songSubTitleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.songCoverImage.layer.cornerRadius = 5
        self.songCoverImage.clipsToBounds = true
    }
}
