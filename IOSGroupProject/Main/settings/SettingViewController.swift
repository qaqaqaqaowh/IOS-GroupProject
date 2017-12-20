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
import MapKit

class SettingViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    var settingsDictionary : [String : Any] = ["Location" : CLLocationCoordinate2D(), "Price" : "Price", "Bedrooms" : "Bedrooms", "Square ft." : "Square ft."]
    var features : [String] = ["Location", "Price", "Bedrooms", "Square ft."]
    var navTitle : UILabel = UILabel()
    let ref = Database.database().reference()

    
    func createNavTitle(_ title: String){
        navTitle = createOptionsLabel(title)
        navTitle.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        self.navigationItem.titleView = navTitle
    }
    
    
    func createLogOutButton() {
        let logOutButton = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(logOutButtonTapped))
        navigationItem.leftBarButtonItem = logOutButton
    }
    @objc func logOutButtonTapped() {
        do {
            try Auth.auth().signOut()
            NotificationCenter.appLogout()
        }
        catch {
            
        }
    }
    
    
    func createEditButton(){
        let button = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = button
    }
    @objc func editButtonTapped(){
        if isEditing {
            navigationItem.rightBarButtonItem?.title = "Edit"
            saveSettings()
            tableView.reloadData()
        }
        else {
            navigationItem.rightBarButtonItem?.title = "Save"
            tableView.reloadData()
        }
        isEditing = !isEditing
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createNavTitle("Search Settings")
        createEditButton()
        createLogOutButton()
        CurrentUser.getSettings {
            DispatchQueue.main.async {
                self.grabCurrentSettings()
                self.tableView.reloadData()
            }
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelectionDuringEditing = true
        // Do any additional setup after loading the view.
    }
    
    
    func grabCurrentSettings() {
        settingsDictionary["Location"] = CurrentUser.location
        settingsDictionary["Price"] = CurrentUser.price
        settingsDictionary["Bedrooms"] = CurrentUser.bedrooms
        settingsDictionary["Square ft."] = CurrentUser.squareFt
        tableView.reloadData()
    }
    
    
    func saveSettings(){
        CurrentUser.location = settingsDictionary["Location"] as! CLLocationCoordinate2D
        CurrentUser.price = settingsDictionary["Price"] as! String
        CurrentUser.bedrooms = settingsDictionary["Bedrooms"] as! String
        CurrentUser.squareFt = settingsDictionary["Square ft."] as! String
        CurrentUser.saveToDatabase()
    }
}

extension SettingViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return features.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "settingsCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell")
        cell.textLabel?.text = "\(features[indexPath.row]):"
        if indexPath.row != 0 {
            cell.detailTextLabel?.text = settingsDictionary[features[indexPath.row]] as? String
        }
        else {
            guard let coordinate = settingsDictionary[features[indexPath.row]] as? CLLocationCoordinate2D
                else{return cell}
            cell.detailTextLabel?.text = String(coordinate.latitude)
        }
        if isEditing {
            cell.detailTextLabel?.textColor = UIColor.blue
        }
        else {
            cell.detailTextLabel?.textColor = UIColor.lightGray
        }
        return cell
    }
}



extension SettingViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            if indexPath.row == 0 {
                let vc = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                vc.delegate = self
                navigationController?.pushViewController(vc, animated: true)
            }
            else if indexPath.row < features.count{
                editCritera(indexPath.row)
            }
        }
    }
    
    
    func editCritera(_ place: Int ) {
        let key = features[place]
        let value = settingsDictionary[key]
        let alertController = UIAlertController(title: key, message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let inputTextField = alertController.textFields![0] as UITextField
            if inputTextField.text != "" {
                guard let newValue =  inputTextField.text
                    else{ return }
                self.settingsDictionary[key] = newValue
                self.tableView.reloadData()
            }
        }))
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = value as? String
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)
    }
}



extension SettingViewController: MapViewPassCoordDelegate {
    
    func passCoord(withLogitude: String, withLatitude: String) {
        guard let logitude = Double(withLogitude),
            let latitude = Double(withLogitude)
            else{return}
        settingsDictionary["Location"] = CLLocationCoordinate2D(latitude: latitude, longitude: logitude)
        tableView.reloadData()
    }
}
