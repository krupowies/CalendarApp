//
//  TrainingUnit.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 29/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import Foundation


class TrainingUnit: Codable {
    var date: String
    var time: String
    var place: String
    var athletes: [String]
    var note: String
    var coach: String
    
    init(date: String, time: String, place: String, athletes: [String], note: String, coach: String) {
        self.date = date
        self.time = time
        self.place = place
        self.athletes = athletes
        self.note = note
        self.coach = coach
    }
    
    init(){
        self.date = ""
        self.time = ""
        self.place = ""
        self.athletes = []
        self.note = ""
        self.coach = ""
    }
    
}
