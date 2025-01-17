//
//  CoachCalendarViewController.swift
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
import FirebaseFirestore

class CoachCalendarViewController: UIViewController {
    
    var athletes = [String]()
    var tempID = ""
    var currentUser = ""
    let db = Firestore.firestore()
    var selectedAthletes = [String]()
    
    
    
    @IBOutlet weak var coachCalendar: FSCalendar!
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    //Pop up view outlets
    @IBOutlet weak var popUpDateLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var athletesTableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtons()
        setUpLabels()
        print(athletes)
        coachCalendar.delegate = self
        athletesTableView.delegate = self
        athletesTableView.dataSource = self
        athletesTableView.allowsMultipleSelection = true
        athletesTableView.allowsMultipleSelectionDuringEditing = true
        setCurrentUsername()
    }
    
    func getSelectedAthletes() -> [String] {
        var selectedAthletes = [String]()
        
        for cell in athletesTableView.visibleCells {
            if cell.accessoryType == UITableViewCell.AccessoryType.checkmark{
                if let currentAthlete = cell.textLabel?.text{
                        selectedAthletes.append(currentAthlete)
                }
            }
        }
        return selectedAthletes
    }
    
    func setCurrentUsername(){
        let currentUserID = Auth.auth().currentUser?.uid
        db.collection(K.FStore.usersCollection)
            .whereField(K.FStore.IDField, isEqualTo: currentUserID as Any)
            .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("Problem with getting athlete data : \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let username = doc.get(K.FStore.usernameField)
                            self.currentUser = username as! String
                        }
                    }
                }
        }
    }
    
    func setTrainingUnit() -> TrainingUnit {
        var currentTraining = TrainingUnit()
        let athletes = getSelectedAthletes()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeOnly = timeFormatter.string(from: timePicker.date)
        if let date = popUpDateLabel.text, let place = placeTextField.text, let note = noteTextField.text {
            currentTraining = TrainingUnit(date: date, time: timeOnly, place: place, athletes: athletes, note: note, coach: currentUser)
        }
        return currentTraining
    }
    
    func getTrainingID(training: TrainingUnit ,callback: @escaping(String) -> Void) {
        var trainingID: String = "init"
        self.db.collection(K.FStore.trainingsCollection)
            .whereField("date", isEqualTo: training.date)
            .whereField("note", isEqualTo: training.note)
            .whereField("place", isEqualTo: training.place)
            .whereField("time", isEqualTo: training.time)
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
    
    func addTrainingAthlete(workout: TrainingAthlete, docID: String){
        let newTrainingAthlete = workout
        let ref: DocumentReference = db.collection(K.FStore.trainingsCollection).document(docID)
        do {
            try ref.collection(K.FStore.athleteStatus).document(newTrainingAthlete.athlete).setData(from: newTrainingAthlete)
        } catch let error {
            print("Error writing workout to Firestore: \(error)")
        }
    }
    
    func getMyAthletes(callback: @escaping([String]) -> Void) {
        var myAthletes: [String] = []
        self.db.collection((K.FStore.usersCollection))
            .whereField(K.FStore.roleField, isEqualTo: "athlete")
            .getDocuments { (querySnapshot, error) in
            if let e = error {
                print("Problem with getting athletes : \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let username = data["username"] as? String {
                            print ("FORLOOP :  \(username)")
                            myAthletes.append(username)
                            callback(myAthletes)
                        }
                    }
                }
            }
        }
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
        popUpDateLabel.text = currentDate
        dateLabel.textColor = .black
    }
    
    func clearPopUp(){
        placeTextField.text = ""
        noteTextField.text = ""
        for cell in athletesTableView.visibleCells {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
    }
    
    func showPopUp() {
        self.view.addSubview(popUpView)
        popUpView.layer.borderWidth = 5
        popUpView.layer.borderColor = UIColor.black.cgColor
        popUpView.center = self.view.center
        popUpView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        popUpView.alpha = 0
        
        clearPopUp()
        
        UIView.animate(withDuration: 0.4) {
            self.popUpView.alpha = 1
            self.popUpView.transform = CGAffineTransform.identity
        }
        
        self.getMyAthletes { (myAthletes) in
            self.athletes = myAthletes
            DispatchQueue.main.async {
                self.athletesTableView.reloadData()
            }
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
    
    @IBAction func closeButtonTap(_ sender: Any) {
        hidePopUp()
    }
        
    @IBAction func setTrainingButtonTap(_ sender: Any) {
        hidePopUp()
        let newTraining = setTrainingUnit()
        do {
            try db.collection(K.FStore.trainingsCollection).document().setData(from: newTraining)
            print("New workout successfully added to Firestore")
        } catch let error {
            print("Error writing workout to Firestore: \(error)")
        }
        self.getTrainingID(training: newTraining) { (currentID) in
            self.tempID = currentID
            DispatchQueue.main.async {
                for athlete in newTraining.athletes{
                    let athleteStatus = TrainingAthlete(athlete: athlete)
                    self.addTrainingAthlete(workout: athleteStatus, docID: self.tempID)
                    print("added subcollection")
                }
            }
        }
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
        popUpDateLabel.text = currentDate
        dateLabel.textColor = .black
    }
}

extension CoachCalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.athletes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = athletesTableView.dequeueReusableCell(withIdentifier: "ReusableAthleteCell", for: indexPath)
        cell.textLabel?.text = self.athletes[indexPath.row]
        print("Cell filled")
        return cell
    }
}

extension CoachCalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
    }
}
