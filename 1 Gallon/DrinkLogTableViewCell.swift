//
//  DrinkLogTableViewCell.swift
//  1 Gallon
//
//  Created by Christian Raroque on 11/26/16.
//  Copyright © 2016 AloaLabs. All rights reserved.
//

import UIKit

class DrinkLogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var topBarLine: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
