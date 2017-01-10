//
//  SettingsViewCell.swift
//  WaveTalk
//
//  Created by Anton Makarov on 10.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class SettingsViewCell: UITableViewCell {

    @IBOutlet weak var nameOfSetting: UILabel!
    @IBOutlet weak var imageSetting: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
