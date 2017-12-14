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
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var listing: Listing = Listing(withURLString: "", withName: "", withOwner: "", withThumb: nil)
    
    var player = AVPlayer()
    
    let controller = AVPlayerViewController()
    
    var delegate: ShowDetailDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoView.backgroundColor = UIColor.black
        let tap = UITapGestureRecognizer(target: self, action: #selector(videoTapped))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(cellSwiped))
        swipe.numberOfTouchesRequired = 1
        swipe.direction = UISwipeGestureRecognizerDirection.left
        videoView.isUserInteractionEnabled = true
        videoView.addGestureRecognizer(tap)
        self.addGestureRecognizer(swipe)
        // Initialization code
    }
    
    @objc func cellSwiped() {
        delegate?.showDetail(withListing: listing)
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
