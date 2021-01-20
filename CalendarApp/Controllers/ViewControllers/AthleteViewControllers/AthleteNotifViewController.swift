//
//  AthleteNotifViewController.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 08/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

class AthleteNotifViewController: UIViewController {
    
    var selectedIndex: IndexPath = IndexPath(row: -1, section: 0)
    var currentUser = ""
    let db = Firestore.firestore()
    
    var athleteTrainings = [TrainingUnit]()
    
    
    @IBOutlet weak var trainingPlanTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrentUsername()
        trainingPlanTable.dataSource = self
        trainingPlanTable.delegate = self
        trainingPlanTable.register(UINib(nibName: "TrainingUnitCell", bundle: nil), forCellReuseIdentifier: "ReusableTrainingCell")
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
    
    func getMyTrainings(callback: @escaping([TrainingUnit]) -> Void) {
        var myTrainings: [TrainingUnit] = []
        self.db.collection(K.FStore.trainingsCollection).whereField("athletes", arrayContains: currentUser)
            .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("Problem with getting training data : \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            let currentUnit = TrainingUnit(date: data["date"] as! String,
                                                           time: data["time"] as! String,
                                                           place: data["place"] as! String,
                                                           athletes: data["athletes"] as! [String],
                                                           note: data["note"] as! String,
                                                           coach: data["coach"] as! String)
                            let ID = doc.documentID
                            
                            self.db.collection(K.FStore.trainingsCollection).document(ID).collection(K.FStore.athleteStatus)
                                .whereField("athlete", isEqualTo: self.currentUser).getDocuments { (querySnapshot, error) in
                                        if let e = error {
                                            print("Problem with getting status : \(e)")
                                        } else {
                                            if let snapshotDocuments = querySnapshot?.documents {
                                                for doc in snapshotDocuments {
                                                    let data = doc.data()
                                                    if data["status"] as! Int == 1 {
                                                        myTrainings.append(currentUnit)
                                                    }
                                                }
                                            }
                                            callback(myTrainings)
                                        }
                                }
                        }
                    }
                }
        }
    }
    

        
    @IBAction func refreshButtonTap(_ sender: Any) {
        getMyTrainings { (trainings) in
            self.athleteTrainings = trainings
            DispatchQueue.main.async {
                self.trainingPlanTable.reloadData()
            }
        }
    }
    
}

extension AthleteNotifViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return athleteTrainings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = trainingPlanTable.dequeueReusableCell(withIdentifier: "ReusableTrainingCell", for: indexPath) as! TrainingUnitCell
        cell.dateLabel.text = athleteTrainings[indexPath.row].date
        cell.placeLabel.text = athleteTrainings[indexPath.row].place
        cell.timeLabel.text = athleteTrainings[indexPath.row].time
        cell.noteLabel.text = athleteTrainings[indexPath.row].note
        cell.selectionStyle = .none
        return cell
    }
    
    
}

extension AthleteNotifViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        trainingPlanTable.beginUpdates()
        trainingPlanTable.reloadRows(at: [selectedIndex], with: .none)
        trainingPlanTable.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
