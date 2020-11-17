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
    
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet var statusPopUpView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
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
    
    func showStatusPopUp(){
        self.view.addSubview(statusPopUpView)
        statusPopUpView.layer.borderWidth = 5
        statusPopUpView.layer.borderColor = UIColor.black.cgColor
        statusPopUpView.center = self.view.center
        
        statusPopUpView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        statusPopUpView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.statusPopUpView.alpha = 1
            self.statusPopUpView.transform = CGAffineTransform.identity
        }
    }
    
    func hidePopUp(){
        UIView.animate(withDuration: 0.4, animations: {
            self.statusPopUpView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.statusPopUpView.alpha = 1
            self.statusPopUpView.transform = CGAffineTransform.identity
        }) { (success: Bool) in
            self.statusPopUpView.removeFromSuperview()
        }
    }
    
    
    @IBAction func statusButtonTap(_ sender: Any) {
        showStatusPopUp()
    }
    
    @IBAction func goingButtonTap(_ sender: Any) {
        statusButton.backgroundColor = .green
        hidePopUp()
    }
    
    @IBAction func notGoingButtonTap(_ sender: Any) {
        statusButton.backgroundColor = .red
        hidePopUp()
    }
    
    @IBAction func undecidedButtonTap(_ sender: Any) {
        statusButton.backgroundColor = .orange
        hidePopUp()
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

            return UIColor.green

        }

        return nil //add your color for default
    }
}

extension AthleteCalendarViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        let currentDate = formatter.string(from: date)
        print("\(currentDate)")
        print("SELECTED !")
        dateLabel.text = currentDate
        dateLabel.textColor = .black
    }
    
}
