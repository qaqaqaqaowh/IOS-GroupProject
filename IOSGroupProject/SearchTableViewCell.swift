//
//  SearchTableViewCell.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/15/17.
//  Copyright © 2017 asd. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var criteriaLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
