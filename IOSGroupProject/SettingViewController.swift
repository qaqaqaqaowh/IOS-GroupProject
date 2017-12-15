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
    
    var editingStat = false
    
    let titleArray = ["Name","Email"]
    
    var infos: [ContactInfo] = []
    
    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        requireLogin()
        tableView.dataSource = self
        getInfos()
        // Do any additional setup after loading the view.
    }
    
    func getInfos() {
        ref.child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (data) in
            guard let validData = data.value as? [String:Any],
                let email = validData["email"] as? String,
            let infosDict = validData["infos"] as? [String:Any],
            let name = infosDict["name"] as? String else {return}
            let emailInfo = ContactInfo(withTitle: "Email", withInfo: email)
            let nameInfo = ContactInfo(withTitle: "Name", withInfo: name)
            DispatchQueue.main.async {
                self.infos.append(emailInfo)
                self.infos.append(nameInfo)
                let indexPath1 = IndexPath(row: self.infos.count - 2, section: 0)
                let indexPath2 = IndexPath(row: self.infos.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath1, indexPath2], with: .right)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func segmentControll(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
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
                infos[index].info = validCell.textField.text
            }
            for info in infos {
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
        return infos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingTableViewCell
        let selectedInfo = infos[indexPath.row]
        if editingStat {
            cell.textField.isUserInteractionEnabled = true
        } else {
            cell.textField.isUserInteractionEnabled = false
        }
        cell.titleLabel.text = selectedInfo.title
        cell.textField.text = selectedInfo.info
        return cell
    }
}
