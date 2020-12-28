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
    
    var testDate = [TrainingUnit]()

    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.db.collection("trainings").whereField("coach", isEqualTo: currentUser)
            .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("Problem with getting training data : \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            
                            
                            
//                            let currentUnit = TrainingUnit(date: data["date"] as! String,
//                            time: data["time"] as! String,
//                            place: data["place"] as! String,
//                            athletes: data["athletes"] as! [String],
//                            note: data["note"] as! String,
//                            coach: data["coach"] as! String)
                            //myTrainings.append(currentUnit)
                        }
                        callback(myTrainings)
                    }
                }
        }
    }
    
    @IBAction func refreshButtonTap(_ sender: Any) {
        getMyTrainings { (trainings) in
            self.testDate = trainings
            DispatchQueue.main.async {
                print("TEST REFRESH : \(self.testDate[0].note)")
                self.coachTableView.reloadData()
            }
        }
    }
}

extension CoachNotifViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 200
        }
}

extension CoachNotifViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        testDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = coachTableView.dequeueReusableCell(withIdentifier: "ReusableCoachCell", for: indexPath) as! TrainingUnitCell
        cell.dateLabel.text = testDate[indexPath.row].date
        cell.placeLabel.text = testDate[indexPath.row].place
        cell.timeLabel.text = testDate[indexPath.row].time
        cell.noteLabel.text = testDate[indexPath.row].note
        cell.selectionStyle = .none
        
        return cell
    }
    
    
}
