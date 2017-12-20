//
//  ListingTableViewCell.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/12/17.
//  Copyright © 2017 asd. All rights reserved.
//
import UIKit
import AVKit
import AVFoundation

protocol ShowDetailDelegate {
    func showDetail(withListing: Listing)
}

class ListingTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var videoView: UIImageView!
    var listing: Listing = Listing()
    var player = AVPlayer()
    let controller = AVPlayerViewController()
    var delegate: ShowDetailDelegate?
    
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var priceImageView: UIImageView!
    @IBOutlet weak var bedroomsImageView: UIImageView!
    @IBOutlet weak var squareFtImageView: UIImageView!

    
    func createSwipeRecognizer(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(cellSwiped))
        swipe.numberOfTouchesRequired = 1
        swipe.direction = UISwipeGestureRecognizerDirection.left
        self.addGestureRecognizer(swipe)
    }
    @objc func cellSwiped() {
        delegate?.showDetail(withListing: listing)
    }
    
    
    func createTapRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(videoTapped))
        videoView.isUserInteractionEnabled = true
        videoView.addGestureRecognizer(tap)
    }
    @objc func videoTapped() {
        controller.view.frame = videoView.bounds
        guard let url = URL(string: listing.videoURL)
            else {return}
        player = AVPlayer(url: url)
        controller.player = player
        videoView.addSubview(controller.view)
        videoView.image = nil
        player.play()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoView.backgroundColor = UIColor.black
        createTapRecognizer()
        createSwipeRecognizer()
    }
}
