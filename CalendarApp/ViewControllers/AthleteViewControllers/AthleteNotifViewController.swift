//
//  AthleteNotifViewController.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 08/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import UIKit

class AthleteNotifViewController: UIViewController {
    
    var selectedIndex: IndexPath = IndexPath(row: -1, section: 0)
    
    struct TrainingData {
        var data: String
        var time: String
        var note: String
        var status: Int
    }
    
    var trainingPlan: [TrainingData] = [
        TrainingData(data: "12.12.20", time: "14:00", note: "Basen 1500m", status: 0),
        TrainingData(data: "14.12.20", time: "08:00", note: "Rower 2h", status: 1),
        TrainingData(data: "17.12.20", time: "10:00", note: "Bieg 4 x 2kn", status: 2)
    ]
    
    @IBOutlet weak var trainingPlanTable: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trainingPlanTable.dataSource = self
        trainingPlanTable.delegate = self
        trainingPlanTable.register(UINib(nibName: "TrainingUnitCell", bundle: nil), forCellReuseIdentifier: "ReusableTrainingCell")
    }
    
}

extension AthleteNotifViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainingPlan.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = trainingPlanTable.dequeueReusableCell(withIdentifier: "ReusableTrainingCell", for: indexPath) as! TrainingUnitCell
        cell.dateLabel.text = trainingPlan[indexPath.row].data
        cell.timeLabel.text = trainingPlan[indexPath.row].time
        cell.noteLabel.text = trainingPlan[indexPath.row].note
        cell.setStatusViewColour(status: trainingPlan[indexPath.row].status)
        cell.selectionStyle = .none
        cell.animate()
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
        if selectedIndex == indexPath { return 200 }
        return 60
    }
}


//ReusableTrainingCell
