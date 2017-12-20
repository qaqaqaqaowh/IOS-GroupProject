//
//  ViewController.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/12/17.
//  Copyright © 2017 asd. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MapKit

class ListingsViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    let ref = Database.database().reference()
    var listings : [Listing] = []
    let pickerView : UIPickerView = UIPickerView()
    let searchOptions : [String] = ["Find Properties", "Saved Properties", "Your Properties"]
    let effectView : UIVisualEffectView = UIVisualEffectView()
    var navTitle : UILabel = UILabel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        CurrentUser.getSettings {
            self.tableView.reloadData()
        }
        tableView.dataSource = self
        tableView.delegate = self
        observeListings()
        createPickerNav()
    }
    
    func observeListings() {
        let sortGroup = DispatchGroup()
        sortGroup.enter()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) {
            sortGroup.leave()
        }
        ref.child("listings").observe(DataEventType.childAdded, with: { (snapshot) in
            let group = DispatchGroup()
            guard let selectedListing = snapshot.value as? [String:Any],
                let location  = selectedListing["location"] as? [String:Any],
                let images    = selectedListing["images"] as? [String],
                let owner     = selectedListing["owner"] as? String,
                let videoUrl  = selectedListing["videoURL"] as? String,
                let price     = selectedListing["price"] as? String,
                let squareFt  = selectedListing["squareFt"] as? String,
                let bedrooms  = selectedListing["bedrooms"] as? String,
                let latitude  = location["latitude"] as? Double,
                let longitude = location["longitude"] as? Double
            else {return}
            sortGroup.activate()
            sortGroup.enter()
            let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let newListing = Listing(listingId: snapshot.key, videoURL: videoUrl, imageURLS: images, price: price, location: locationCoordinate, squareFt: squareFt, bedrooms: bedrooms, owner: owner)
            
            for imageUrl in newListing.imageURLS {
                group.enter()
                guard let url = URL(string: imageUrl)
                    else{return}
                let manager = URLSession.shared
                let dataTask = manager.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let validData = data, let image = UIImage(data: validData) {
                        newListing.images.append(image)
                        group.leave()
                    }
                })
                dataTask.resume()
            }
            group.notify(queue: .main, execute: {
                self.listings.append(newListing)
                sortGroup.leave()
                let indexPath = IndexPath(row: self.listings.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.right)
            })
        })
        sortGroup.notify(queue: .main) {
            self.sortListings(self.listings)
        }
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
        if isDistanceInRange(long1: String(selectedListing.location.longitude), lat1: String(selectedListing.location.latitude), long2: String(CurrentUser.location.longitude), lat2: String(CurrentUser.location.latitude), range: "10000") {
            cell.locationImageView.image = UIImage(named: "true")
        } else {
            cell.locationImageView.image = UIImage(named: "false")
        }
        if selectedListing.price <= CurrentUser.price {
            cell.priceImageView.image = UIImage(named: "true")
        } else {
            cell.priceImageView.image = UIImage(named: "false")

        }
        if selectedListing.bedrooms >= CurrentUser.bedrooms {
            cell.bedroomsImageView.image = UIImage(named: "true")
        } else {
            cell.bedroomsImageView.image = UIImage(named: "false")
        }
        if selectedListing.squareFt >= CurrentUser.bedrooms {
            cell.squareFtImageView.image = UIImage(named: "true")
        } else {
            cell.squareFtImageView.image = UIImage(named: "false")
        }
        cell.delegate = self
        return cell
    }
}


extension ListingsViewController : UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height
    }
}

extension ListingsViewController : ShowDetailDelegate {
    
    
    func showDetail(withListing: Listing) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        vc.selectedListing = withListing
        navigationController?.pushViewController(vc, animated: true)
    }
}
