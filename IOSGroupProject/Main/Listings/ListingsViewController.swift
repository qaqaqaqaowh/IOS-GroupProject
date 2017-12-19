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
    let pickerView : UIPickerView = UIPickerView()
    let options : [String] = ["Find Properties", "Saved Properties", "Your Properties"]
    let effectView : UIVisualEffectView = UIVisualEffectView()
    var navTitle : UILabel = UILabel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        observeListings()
        createPickerNav()
    }
    
    
    func observeListings() {
        ref.child("listings").observe(DataEventType.childAdded, with: { (snapshot) in
            guard let selectedListing = snapshot.value as? [String:Any],
                let location  = selectedListing["location"] as? [String:Any],
                let images    = selectedListing["images"] as? [String:Any],
                let owner     = selectedListing["owner"] as? String,
                let videoUrl  = selectedListing["videoURL"] as? String,
                let price     = selectedListing["price"] as? String,
                let squareFt  = selectedListing["squareFt"] as? String,
                let bedrooms  = selectedListing["bedrooms"] as? String,
                let latitude  = location["latitude"] as? String,
                let longitude = location["longitude"] as? String
                
//                let url = URL(string: thumbURL)
            else {return}
            
            let newListing = Listing(listingId: snapshot.key, videoURL: videoUrl, imageURLS: ["https://firebasestorage.googleapis.com/v0/b/cribs-53001.appspot.com/o/images%2F-L0d_5iR65CpX9QUdJnA?alt=media&token=98173745-5128-478e-8822-db4d3ad0824f"], price: price, latitude: latitude, longitude: longitude, squareFt: squareFt, bedrooms: bedrooms, owner: owner)
            guard let url = URL(string: newListing.imageURLS[0])
                else{return}
            let manager = URLSession.shared
            let dataTask = manager.dataTask(with: url, completionHandler: { (data, response, error) in
                if let validData = data,
                    let image = UIImage(data: validData){
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
}

extension ListingsViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listings.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListingTableViewCell
        let selectedListing = listings[indexPath.row]
        cell.listing = selectedListing
        cell.videoView.image = selectedListing.images[0]
        cell.delegate = self
        return cell
    }
}


extension ListingsViewController: ShowDetailDelegate {
    
    
    func showDetail(withListing: Listing) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
//        vc.listing = withListing
        navigationController?.pushViewController(vc, animated: true)
    }
}
