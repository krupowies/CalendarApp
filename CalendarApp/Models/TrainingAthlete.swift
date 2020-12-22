//
//  TrainingAthlete.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 18/12/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import Foundation

class TrainingAthlete: Codable {
    var athlete: String
    var status: Int
    
    init(athlete: String){
        self.athlete = athlete
        self.status = 0
    }
}
