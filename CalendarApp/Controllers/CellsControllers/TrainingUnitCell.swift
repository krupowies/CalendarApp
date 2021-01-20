//
//  TrainingUnitCell.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 12/12/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import UIKit

class TrainingUnitCell: UITableViewCell {
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusView.layer.borderWidth = 5
        statusView.layer.borderColor = UIColor.black.cgColor
        statusView.layer.cornerRadius = 10
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
