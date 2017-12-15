//
//  SettingViewController.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/14/17.
//  Copyright © 2017 asd. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SettingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchTableView: UITableView!
    
    var editingStat = false
    
    let titleArray = ["Name","Email"]
    
    var info: [ContactInfo] = []
    
    var settings: [Setting] = []
    
    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        requireLogin()
        tableView.dataSource = self
        searchTableView.dataSource = self
        searchTableView.delegate = self
        getInfo()
        getSettings()
        // Do any additional setup after loading the view.
    }
    
    func getInfo() {
        ref.child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (data) in
            guard let validData = data.value as? [String:Any],
                let email = validData["email"] as? String,
            let infoDict = validData["info"] as? [String:Any],
            let name = infoDict["name"] as? String else {return}
            let emailInfo = ContactInfo(withTitle: "Email", withInfo: email)
            let nameInfo = ContactInfo(withTitle: "Name", withInfo: name)
            DispatchQueue.main.async {
                self.info.append(emailInfo)
                self.info.append(nameInfo)
                let indexPath1 = IndexPath(row: self.info.count - 2, section: 0)
                let indexPath2 = IndexPath(row: self.info.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath1, indexPath2], with: .right)
            }
        })
    }
    
    func getSettings() {
        ref.child("users").child((Auth.auth().currentUser?.uid)!).child("settings").observeSingleEvent(of: .value, with: { (data) in
            guard let validData = data.value as? [String:Any],
                let location = validData["location"] as? [String:Any],
                let longtitude = location["longtitude"] as? String,
                let latitude = location["latitude"] as? String,
                let numOfRooms = validData["numOfRooms"] as? String,
                let size = validData["size"] as? String else {return}
            let longtitudeSetting = Setting(withCriteria: "Longitude", withValue: longtitude)
            let latitudeSetting = Setting(withCriteria: "Latitude", withValue: latitude)
            let numOfRoomsSetting = Setting(withCriteria: "Number Of Rooms", withValue: numOfRooms)
            let sizeSetting = Setting(withCriteria: "Size", withValue: size)
            DispatchQueue.main.async {
                self.settings.append(longtitudeSetting)
                self.settings.append(latitudeSetting)
                self.settings.append(numOfRoomsSetting)
                self.settings.append(sizeSetting)
                let indexPath1 = IndexPath(row: self.settings.count - 4, section: 0)
                let indexPath2 = IndexPath(row: self.settings.count - 3, section: 0)
                let indexPath3 = IndexPath(row: self.settings.count - 2, section: 0)
                let indexPath4 = IndexPath(row: self.settings.count - 1, section: 0)
                self.searchTableView.insertRows(at: [indexPath1,indexPath2,indexPath3,indexPath4], with: .right)
            }
        })
    }
    
    @IBAction func segmentControll(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tableView.isHidden = false
            searchTableView.isHidden = true
        } else {
            tableView.isHidden = true
            searchTableView.isHidden = false
        }
    }
    
    @IBAction func editButtonAction(_ sender: UIBarButtonItem) {
        editingStat = !editingStat
        if editingStat {
            sender.title = "Save"
        } else {
            sender.title = "Edit"
            for (index, cell) in tableView.visibleCells.enumerated() {
                guard let validCell = cell as? SettingTableViewCell else {return}
                info[index].info = validCell.textField.text
            }
            for info in info {
                if info.title == "Name" {
                    ref.child("users").child((Auth.auth().currentUser?.uid)!).child("infos").updateChildValues(["name":info.info])
                } else if info.title == "Email" {
                    ref.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["email":info.info])
                }
            }
        }
        tableView.reloadData()
    }
    
    
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView {
            return info.count
        } else if searchTableView == tableView {
            return settings.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingTableViewCell
            let selectedInfo = info[indexPath.row]
            if editingStat {
                cell.textField.isUserInteractionEnabled = true
            } else {
                cell.textField.isUserInteractionEnabled = false
            }
            cell.titleLabel.text = selectedInfo.title
            cell.textField.text = selectedInfo.info
            return cell
        } else {
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
            let selectedSetting = settings[indexPath.row]
            if editingStat {
                cell.isUserInteractionEnabled = true
            } else {
                cell.isUserInteractionEnabled = false
            }
            cell.criteriaLabel.text = selectedSetting.criteria
            cell.valueLabel.text = String(describing: selectedSetting.value)
            return cell
        }
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchTableView {
            let selectedSetting = settings[indexPath.row]
            if selectedSetting.criteria == "Latituide" || selectedSetting.criteria == "Longtitude" {
                // Display map
            } else if selectedSetting.criteria == "Number Of Rooms" {
                // Prompt number of rooms
            } else if selectedSetting.criteria == "Size" {
                // Prompt size of property
            }
        }
    }
}

extension SettingViewController: MapViewPassCoordDelegate {
    func passCoord(withLogitude: String, withLatitude: String) {
        for cell in searchTableView.visibleCells {
            let searchCell = cell as! SearchTableViewCell
            if searchCell.criteriaLabel.text == "Longitude" {
                searchCell.valueLabel.text = withLogitude
            } else if searchCell.criteriaLabel.text == "Latitude" {
                searchCell.valueLabel.text = withLatitude
            }
        }
        for setting in settings {
            if setting.criteria == "Longitude" {
                setting.criteria = withLogitude
            } else if setting.criteria == "Latitude" {
                setting.criteria = withLatitude
            }
        }
        searchTableView.reloadData()
    }
}
