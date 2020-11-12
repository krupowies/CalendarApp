//
//  AthleteCalendarViewController.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 08/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import UIKit
import FSCalendar

class AthleteCalendarViewController: UIViewController {
    
    
    @IBOutlet weak var athleteCalendar: FSCalendar!
    
    var datesWithEvent = ["2020-11-03", "2020-11-06", "2020-11-12", "2020-11-25"]

    var datesWithMultipleEvents = ["2020-10-08", "2020-10-16", "2020-10-20", "2020-10-28"]

    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        athleteCalendar.dataSource = self
        athleteCalendar.delegate = self
    }
}

extension AthleteCalendarViewController: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {

        let dateString = self.dateFormatter2.string(from: date)

        if self.datesWithEvent.contains(dateString) {
            return 1
        }

        if self.datesWithMultipleEvents.contains(dateString) {
            return 3
        }

        return 0
    }
}

extension AthleteCalendarViewController: FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        let dateString = self.dateFormatter2.string(from: date)
        
        if datesWithEvent.contains(dateString) {

            return UIColor.purple

        }

        return nil //add your color for default
    }
    
    
}
