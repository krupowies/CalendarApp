//
//  Coach.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 28/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import Foundation

class Coach: Codable {
    var email: String
    var username: String
    var role: String
    var ID: String
    var myAthletes: [String]
    
    init(email: String, username: String, role: String, ID: String, myAthletes: [String]) {
        self.email = email
        self.username = username
        self.role = role
        self.ID = ID
        self.myAthletes = myAthletes
    }
}
