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
    
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var coachLabel: UILabel!
    
    
    
    @IBOutlet weak var athleteCalendar: FSCalendar!
    
    let db = Firestore.firestore()
    var currentUser = ""
    var currentUnit = TrainingUnit()
    var currentTrainingID = ""
    var currentTrainingStatus = 0
    
    var datesWithEvent = ["11-11-2020", "12-11-2020", "13-11-2020", "14-11-2020"]
    
    var testDate = [String]()
    var testID = [String]()

    var datesWithMultipleEvents = ["01-11-2020", "02-11-2020", "03-11-2020", "04-11-2020"]

    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtons()
        setUpLabels()
        athleteCalendar.dataSource = self
        athleteCalendar.delegate = self
        setCurrentUsername()
        self.getMyTrainings { (trainings) in
            self.testDate = trainings
            DispatchQueue.main.async {
                print(self.testDate)
            }
            print(self.testDate)
        }
    }
    
    func setUpButtons(){
        closeButton.layer.borderWidth = 3
        closeButton.layer.borderColor = UIColor.systemRed.cgColor
        statusButton.backgroundColor = .white
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
        self.db.collection("trainings").whereField("athletes", arrayContains: currentUser)
            .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("Problem with getting training data : \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
//                            let tempID = doc.documentID
//                            myTrainings.append(tempID)
//                            print("FUNC : \(tempID )")
                            let tempDate = doc.get("date")
                            myTrainings.append(tempDate as! String)
                            print("FUNC : \(tempDate as! String)")
                            callback(myTrainings)
                        }
                    }
                }
        }
    }
    
    func getTrainingDate(ID: String, callback: @escaping (String)-> Void) {
        var currentDate = ""
        self.db.collection("trainings").document(ID).getDocument { (documentSnapshot, error) in
            if let e = error {
                print("Problem with getting training date : \(e)")
            } else {
                currentDate = documentSnapshot?.get("date") as! String
                print("TEST : \(currentDate)")
                callback(currentDate)
            }
        }
    }
    
    func getTrainingInfo(date: String, callback: @escaping (TrainingUnit) -> Void)  {
        var currentUnit = TrainingUnit()
        self.db.collection("trainings")
            .whereField("date", isEqualTo: date).getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("Problem with getting training info : \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            currentUnit = TrainingUnit(date: date,
                                                       time: data["time"] as! String,
                                                       place: data["place"] as! String,
                                                       athletes: data["athletes"] as! [String],
                                                       note: data["note"] as! String,
                                                       coach: data["coach"] as! String)
                            callback(currentUnit)
                        }
                    }
                }
        }
    }
    
    func getTrainingID(date: String ,callback: @escaping(String) -> Void) {
        var trainingID: String = "init"
        self.db.collection("trainings")
            .whereField("date", isEqualTo: date)
            .getDocuments { (querySnapshot, error) in
            if let e = error {
                print("Problem with getting workout ID : \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        trainingID = doc.documentID
                        callback(trainingID)
                    }
                }
            }
        }
    }
    
    func getTrainingStatus(date: String, callback: @escaping (Int) -> Void) {
        var status: Int = 0
        self.getTrainingID(date: date) { (currentID) in
            self.currentTrainingID = currentID
            DispatchQueue.main.async {
                self.db.collection("trainings")
                    .document(self.currentTrainingID).collection("testSubCol")
                    .whereField("athlete", isEqualTo: self.currentUser).getDocuments { (querySnapshot, error) in
                        if let e = error {
                            print("Problem with getting status : \(e)")
                        } else {
                            if let snapshotDocuments = querySnapshot?.documents {
                                for doc in snapshotDocuments {
                                    let data = doc.data()
                                    status = data["status"] as! Int
                                    callback(status)
                                }
                            }
                        }
                }
            }
        }
    }
    
    func setTrainingStatus(status: Int){
        self.db.collection("trainings").document(self.currentTrainingID)
            .collection("testSubCol").document(self.currentUser).updateData(["status" : status]) { (error) in
                if let e = error {
                    print("Problem with setting status : \(e)")
                } else {
                    print("Status updated successfully")
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
    
    @IBAction func refreshButtonTap(_ sender: Any) {
        self.getMyTrainings { (trainings) in
            self.testDate = trainings
            DispatchQueue.main.async {
                self.athleteCalendar.reloadData()
                print("refresh 1 \(self.testDate)")
//                for id in self.testID {
//                    self.getTrainingDate(ID: id) { (currentDate) in
//                        self.testDate.append(currentDate)
//                        print("refresh 2 \(self.testDate)")
//                    }
//                }
//                DispatchQueue.main.async {
//                    self.athleteCalendar.reloadData()
//                }
            }
        }
    }
    
    
    @IBAction func statusButtonTap(_ sender: Any) {
        showStatusPopUp()
    }
    
    @IBAction func goingButtonTap(_ sender: Any) {
        statusButton.backgroundColor = .green
        setTrainingStatus(status: 1)
        hidePopUp()
    }
    
    @IBAction func notGoingButtonTap(_ sender: Any) {
        statusButton.backgroundColor = .red
        setTrainingStatus(status: 2)
        hidePopUp()
    }
    
    @IBAction func undecidedButtonTap(_ sender: Any) {
        statusButton.backgroundColor = .orange
        setTrainingStatus(status: 0)
        hidePopUp()
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        hidePopUp()
    }
    
    
}

extension AthleteCalendarViewController: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {

        let dateString = self.dateFormatter2.string(from: date)

        if self.testDate.contains(dateString) {
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
        
        if testDate.contains(dateString) {

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
        self.getTrainingStatus(date: currentDate) { (trainingStatus) in
            self.currentTrainingStatus = trainingStatus
            DispatchQueue.main.async {
                switch self.currentTrainingStatus {
                case 0:
                    self.statusButton.backgroundColor = .systemOrange
                case 1:
                    self.statusButton.backgroundColor = .systemGreen
                case 2:
                    self.statusButton.backgroundColor = .systemRed
                default:
                    self.statusButton.backgroundColor = .white
                }
            }
        }
        self.getTrainingInfo(date: currentDate) { (trainingUnit) in
            self.currentUnit = trainingUnit
            DispatchQueue.main.async {
                print("note : \(self.currentUnit.note)")
                self.placeLabel.text = self.currentUnit.place
                self.timeLabel.text = self.currentUnit.time
                self.noteLabel.text = self.currentUnit.note
                self.coachLabel.text = self.currentUnit.coach
            }
        }
    }
    
}
