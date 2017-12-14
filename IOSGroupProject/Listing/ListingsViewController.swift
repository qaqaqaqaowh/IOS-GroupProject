//
//  ViewController.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/12/17.
//  Copyright © 2017 asd. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let ref = Database.database().reference()
    
    var listings : [Listing] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        observeListings()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func observeListings() {
        ref.child("listings").observe(DataEventType.childAdded, with: { (snapshot) in
            guard let listings = snapshot.value as? [String:Any],
            let urlString = listings["videoURL"] as? String,
            let name = listings["name"] as? String,
            let ownerUID = listings["owner"] as? String,
            let thumbURL = listings["thumb"] as? String,
            let url = URL(string: thumbURL) else {return}
            let manager = URLSession.shared
            let dataTask = manager.dataTask(with: url, completionHandler: { (data, response, error) in
                if let validData = data,
                    let image = UIImage(data: validData){
                    let newListing = Listing(withURLString: urlString, withName: name, withOwner: ownerUID, withThumb: image)
                    DispatchQueue.main.async {
                        self.listings.append(newListing)
                        let indexPath = IndexPath(row: self.listings.count - 1, section: 0)
                        self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.right)
                    }
                }
            })
            dataTask.resume()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ListingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listings.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListingTableViewCell
        let selectedListing = listings[indexPath.row]
        cell.listing = selectedListing
        cell.nameLabel.text = selectedListing.name
        cell.videoView.image = selectedListing.thumbImage
        cell.delegate = self
        return cell
    }
}

extension ListingsViewController: ShowDetailDelegate {
    func showDetail(withListing: Listing) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        vc.listing = withListing
        navigationController?.pushViewController(vc, animated: true)
    }
}
