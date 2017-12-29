//
//  RankingCellPrototypeTableViewCell.swift
//  iKnow
//
//  Created by Arturo Iafrate on 27/09/17.
//  Copyright © 2017 Arturo Iafrate. All rights reserved.
//

import UIKit

class RankingCellPrototypeTableViewCell: UITableViewCell {
    @IBOutlet weak var playerColor: UIImageView!
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var playerScore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
