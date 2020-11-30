//
//  Athlete.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 28/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import Foundation


class Athlete: Codable {
    var email: String
    var username: String
    var role: String
    var ID: String
    var myCoaches: [String]
    
    init(email: String, username: String, role: String, ID: String, myCoaches: [String]) {
        self.email = email
        self.username = username
        self.role = role
        self.ID = ID
        self.myCoaches = myCoaches
    }
}
