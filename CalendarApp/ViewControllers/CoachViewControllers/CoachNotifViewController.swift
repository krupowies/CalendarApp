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
}
