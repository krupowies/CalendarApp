//
//  CoachTrainingCell.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 28/12/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import UIKit

class CoachTrainingCell: UITableViewCell {
    
    @IBOutlet weak var athleteLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
