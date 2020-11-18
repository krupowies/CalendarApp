//
//  CoachCalendarViewController.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 08/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import UIKit
import FSCalendar

class CoachCalendarViewController: UIViewController {
    
    @IBOutlet weak var coachCalendar: FSCalendar!
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    //Pop up view outlets
    @IBOutlet weak var popUpDateLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coachCalendar.delegate = self
    }
    
    func showPopUp() {
        self.view.addSubview(popUpView)
        popUpView.layer.borderWidth = 5
        popUpView.layer.borderColor = UIColor.black.cgColor
        popUpView.center = self.view.center
        
        popUpView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        popUpView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.popUpView.alpha = 1
            self.popUpView.transform = CGAffineTransform.identity
        }
    }
    
    func hidePopUp(){
        UIView.animate(withDuration: 0.4, animations: {
            self.popUpView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.popUpView.alpha = 1
            self.popUpView.transform = CGAffineTransform.identity
        }) { (success: Bool) in
            self.popUpView.removeFromSuperview()
        }
    }
    
    @IBAction func addButtonTap(_ sender: Any) {
        showPopUp()
    }
    
    @IBAction func dismissPopUp(_ sender: Any) {
        hidePopUp()
    }
    
    
}

extension CoachCalendarViewController: FSCalendarDelegate {
     
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        let currentDate = formatter.string(from: date)
        print("\(currentDate)")
        print("SELECTED !")
        dateLabel.text = currentDate
        dateLabel.textColor = .lightGray
    }
}
