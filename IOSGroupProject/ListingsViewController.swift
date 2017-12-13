//
//  ViewController.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/12/17.
//  Copyright © 2017 asd. All rights reserved.
//

import UIKit

class ListingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var listings : [Listing] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let newListing = Listing(withURLString: "https://firebasestorage.googleapis.com/v0/b/project-187307.appspot.com/o/IMG_3810.MOV?alt=media&token=6a8c9c19-953a-49c1-9783-f7f91f7d51a6", withViewCount: 2)
        listings.append(newListing)
        tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
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
        cell.viewCount.text = String(selectedListing.viewCount)
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
