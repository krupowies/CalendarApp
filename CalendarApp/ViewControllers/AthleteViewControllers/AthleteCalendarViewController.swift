//
//  AthleteCalendarViewController.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 08/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import UIKit
import FSCalendar
import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift

class AthleteCalendarViewController: UIViewController {
    
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet var statusPopUpView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    
    @IBOutlet weak var athleteCalendar: FSCalendar!
    
    let db = Firestore.firestore()
    var currentUser = ""
    
    var datesWithEvent = ["2020-11-03", "2020-11-06", "2020-11-12", "2020-11-25"]
    
    var testDate = [String]()

    var datesWithMultipleEvents = ["2020-10-08", "2020-10-16", "2020-10-20", "2020-10-28"]

    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtons()
        setUpLabels()
        athleteCalendar.dataSource = self
        athleteCalendar.delegate = self
        setCurrentUsername()
    }
    
    func setUpButtons(){
        closeButton.layer.borderWidth = 3
        closeButton.layer.borderColor = UIColor.systemRed.cgColor
    }
    
    func setUpLabels(){
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        let currentDate = formatter.string(from: date)
        dateLabel.text = currentDate
        dateLabel.textColor = .black
    }
    
    func setCurrentUsername(){
        let currentUserID = Auth.auth().currentUser?.uid
        db.collection(K.FStore.usersCollection)
            .whereField("ID", isEqualTo: currentUserID as Any)
            .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("Problem with getting athlete data : \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let username = doc.get("username")
                            self.currentUser = username as! String
                        }
                    }
                }
        }
    }
    
    func getMyTrainings(callback: @escaping([String]) -> Void) {
        var myTrainings: [String] = []
        self.db.collection("training Athlete")
        .whereField("athlete", isEqualTo: currentUser)
            .getDocuments { (querySnapshot, error) in
            if let e = error {
                print("Problem with getting training data : \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        print("DUPA TEST")
                        let trainingID = doc.get("trainingID")
                        myTrainings.append(trainingID as! String)
                        print("FUNC: \(trainingID as! String)")
                        callback(myTrainings)
                    }
                }
            }
        }
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
        
        getMyTrainings { (dates) in
            self.testDate = dates
            DispatchQueue.main.async {
                print("show pop up : \(self.testDate)")
            }
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
        print(currentUser)
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
    
    @IBAction func closeButtonTap(_ sender: Any) {
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
