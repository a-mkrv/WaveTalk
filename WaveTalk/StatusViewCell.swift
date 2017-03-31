//
//  StatusViewCell.swift
//  WaveTalk
//
//  Created by Anton Makarov on 31.03.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class StatusViewCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var imageState: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
