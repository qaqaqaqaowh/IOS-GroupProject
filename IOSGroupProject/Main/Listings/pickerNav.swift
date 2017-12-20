//
//  pickerNav.swift
//  IOSGroupProject
//
//  Created by Jacob Schantz on 12/15/17.
//
//  ViewController.swift
//  pickerView
//
//  Created by Jacob Schantz on 12/13/17.
//  Copyright © 2017 Jake Schantz. All rights reserved.
//

import UIKit
import MapKit

extension ListingsViewController {
    
    
    func createPickerView(){
        pickerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height-113)
        pickerView.alpha = 0.0
        effectView.contentView.addSubview(pickerView)
    }
    
    
    func createBlurView(){
        view.addSubview(effectView)
        createPickerView()
        effectView.frame = view.frame
        self.effectView.effect = nil
        self.effectView.isHidden = true
    }
    
    
    func blurView(){
        if !effectView.isHidden {
            UIView.animate(withDuration: 0.5, animations: {
                self.effectView.effect = nil
                self.pickerView.alpha = 0.0
                self.navigationItem.leftBarButtonItem?.image = UIImage(named: "switch")
            }, completion: { (bool) in
                self.effectView.isHidden = true
            })
        }
        else {
            self.effectView.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.effectView.effect = UIBlurEffect(style: .dark)
                self.pickerView.alpha = 1.0
                self.navigationItem.leftBarButtonItem?.image = UIImage(named: "x")
            }, completion: { (bool) in
                print("nil")
            })
        }
    }
    
    
    func createNavTitle(_ title: String){
        navTitle = createOptionsLabel(title)
        navTitle.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        self.navigationItem.titleView = navTitle
    }
    
    
    func createNewListingButton(){
        let button = UIBarButtonItem(title: "New", style: .done, target: self, action: #selector(newListingButtonTapped))
        navigationItem.rightBarButtonItem = button
    }
    @objc func newListingButtonTapped(){
        let vc = UploadVideoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func createSwitchButton(){
        let image = UIImage(named: "switch")
        let imageButton = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(switchButtonTapped))
        navigationItem.leftBarButtonItem = imageButton
    }
    @objc func switchButtonTapped() {
        pickerView.isUserInteractionEnabled = true
        blurView()
    }
    
    
    func createPickerNav(){
        createNavTitle("Find Properties")
        createBlurView()
        createSwitchButton()
        createNewListingButton()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
    }
}



extension ListingsViewController : UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return searchOptions.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return view.frame.height/5
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return createOptionsLabel(searchOptions[row])
    }
}



extension ListingsViewController : UIPickerViewDelegate {
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        createNavTitle(searchOptions[row])
        pickerView.isUserInteractionEnabled = false
        blurView()
        listings = []
        let sortGroup = DispatchGroup()
        if row == 0 {
            ref.child("listings").observe(.childAdded, with: { (snapshot) in
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
                let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let newListing = Listing(listingId: snapshot.key, videoURL: videoUrl, imageURLS: images, price: price, location: locationCoordinate, squareFt: squareFt, bedrooms: bedrooms, owner: owner)
                sortGroup.enter()
                
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
        } else if row == 1 {
            var listingsUID: [String] = []
            let fetchListingGroup = DispatchGroup()
            ref.child("users").child(CurrentUser.uid).child("saved").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String:Any] else {return}
                for (_, _) in dictionary.enumerated() {
                    fetchListingGroup.enter()
                }
                for (key, _) in dictionary {
                    listingsUID.append(key)
                    fetchListingGroup.leave()
                }
                fetchListingGroup.notify(queue: .main, execute: { 
                    for uid in listingsUID {
                        self.ref.child("listings").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
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
                    }
                })
            })
        } else if row == 2 {
            var listingsUID: [String] = []
            let fetchListingGroup = DispatchGroup()
            ref.child("users").child(CurrentUser.uid).child("listings").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String:Any] else {return}
                for (_, _) in dictionary.enumerated() {
                    fetchListingGroup.enter()
                }
                for (key, _) in dictionary {
                    listingsUID.append(key)
                    fetchListingGroup.leave()
                }
                fetchListingGroup.notify(queue: .main, execute: {
                    for uid in listingsUID {
                        self.ref.child("listings").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
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
                    }
                })
            })
        }
        sortGroup.notify(queue: .main) { 
            self.sortListings(self.listings)
        }
        tableView.reloadData()
    }
    
    func sortListings(_ listings:[Listing]) {
        let group = DispatchGroup()
        for _ in 0..<listings.count {
            group.enter()
        }
        for listing in listings {
            if listing.bedrooms >= CurrentUser.bedrooms {
                listing.score += 1
            }
            if isDistanceInRange(long1: String(listing.location.longitude), lat1: String(listing.location.latitude), long2: String(CurrentUser.location.longitude), lat2: String(CurrentUser.location.latitude), range: "10000") {
                listing.score += 1
            }
            if listing.price <= CurrentUser.price {
                listing.score += 1
            }
            if listing.squareFt >= CurrentUser.squareFt {
                listing.score += 1
            }
            group.leave()
        }
        group.notify(queue: .main) {
            let sort = NSSortDescriptor(key: "score", ascending: false)
            let sortedListing = (listings as NSArray).sortedArray(using: [sort]) as! [Listing]
            self.listings = sortedListing
            self.tableView.reloadData()
        }
    }
    
}

