//
//  TypeTableViewCell.swift
//  1 Gallon
//
//  Created by Christian Raroque on 11/26/16.
//  Copyright © 2016 AloaLabs. All rights reserved.
//

import UIKit

class TypeTableViewCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
