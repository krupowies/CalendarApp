//
//  CoachNotifViewController.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 08/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift

class CoachNotifViewController: UIViewController {
    
    @IBOutlet weak var coachTableView: UITableView!
    var currentUser = ""
    let db = Firestore.firestore()
    var delete: Bool = false
    
    var testDate = [CellInfo]()
    
    struct CellInfo {
        var date: String
        var time: String
        var place: String
        var athlete: String
        var status: Int
        var note: String
    }

    override func viewDidLoad() {
        setCurrentUsername()
        super.viewDidLoad()
        coachTableView.dataSource = self
        coachTableView.delegate = self
        coachTableView.register(UINib(nibName: "CoachTrainingCell", bundle: nil), forCellReuseIdentifier: "ReusableCoachCell")
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
                            print(self.currentUser)
                        }
                    }
                }
        }
    }
    
    func deleteTrainingAthlete(training: CellInfo,callback: @escaping(Bool) -> Void){
        var docID = ""
        self.db.collection("trainings")
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
                        docID = doc.documentID
                        self.db.collection("trainings").document(docID).updateData([
                            "athletes": FieldValue.arrayRemove([training.athlete])
                        ])
                        self.db.collection("trainings").document(docID).collection("testSubCol").document(training.athlete).delete { (error) in
                            if let e = error {
                                print("Error removing document: \(e)")
                            } else {
                                print("Document from subcollection successfully removed!")
                            }
                        }
                        callback(true)
                    }
                }
            }
        }
    }
    
    func getMyTrainings(callback: @escaping([CellInfo]) -> Void) {
        var myTrainings: [CellInfo] = []
        print("Func : \(self.currentUser)")
        self.db.collection("trainings").whereField("coach", isEqualTo: currentUser)
            .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("Problem with getting training data : \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            var currentTraining = CellInfo(date: data["date"] as! String,
                                                           time: data["time"] as! String,
                                                           place: data["place"] as! String,
                                                           athlete: "",
                                                           status: 0,
                                                           note: data["note"] as! String)
                            
                            let ID = doc.documentID
                            
                            self.db.collection("trainings").document(ID).collection("testSubCol").getDocuments { (querySnapshot, error) in
                                if let e = error {
                                    print("Problem with getting sub-data : \(e)")
                                } else {
                                    if let snapshotDocuments = querySnapshot?.documents {
                                        for doc in snapshotDocuments {
                                            let subData = doc.data()
                                            currentTraining.athlete = subData["athlete"] as! String
                                            currentTraining.status = subData["status"] as! Int
                                            print("success ! : \(currentTraining.athlete), \(currentTraining.note), \(currentTraining.status)")
                                            myTrainings.append(currentTraining)
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
    
    @IBAction func refreshButtonTap(_ sender: Any) {
        getMyTrainings { (trainings) in
            self.testDate = trainings
            DispatchQueue.main.async {
                print("TEST REFRESH : \(self.testDate.count)")
                self.coachTableView.reloadData()
                print("reloaded")
            }
        }
    }
}

extension CoachNotifViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        testDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = coachTableView.dequeueReusableCell(withIdentifier: "ReusableCoachCell", for: indexPath) as! CoachTrainingCell
        cell.athleteLabel.text = testDate[indexPath.row].athlete
        cell.dateLabel.text = testDate[indexPath.row].date
        cell.placeLabel.text = testDate[indexPath.row].place
        cell.timeLabel.text = testDate[indexPath.row].time
        cell.noteLabel.text = testDate[indexPath.row].note
        cell.setStatusViewColour(status: testDate[indexPath.row].status)
        cell.selectionStyle = .none
        
        return cell
    }
}

extension CoachNotifViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 200
        }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            deleteTrainingAthlete(training: testDate[indexPath.row]) { (ifDelete) in
                print("SIEMA1")
                self.delete = ifDelete
                DispatchQueue.main.async {
                    print("SIEMA2")
                    print(self.testDate[indexPath.row].athlete)
                    self.coachTableView.beginUpdates()
                    self.testDate.remove(at: indexPath.row)
                    self.coachTableView.deleteRows(at: [indexPath], with: .fade)
                    self.coachTableView.endUpdates()
                    print(self.delete)
                }
            }
        }
    }
}
