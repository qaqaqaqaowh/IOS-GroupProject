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
    
    @IBOutlet weak var videoView: AVPlayerViewController!
    
    @IBOutlet weak var viewCount: UILabel!
    
    var listing: Listing = Listing(withURLString: "", withViewCount: 0)
    
    var player = AVPlayer()
    
    var delegate: ShowDetailDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewCount.text = String(listing.viewCount)
        videoView.player = player
        let tap = UITapGestureRecognizer(target: self, action: #selector(videoTapped))
        videoView.view.isUserInteractionEnabled = true
        videoView.view.addGestureRecognizer(tap)
        // Initialization code
    }
    
    @objc func videoTapped() {
        guard let url = URL(string: listing.videoURL)
            else {return}
        player = AVPlayer(url: url)
        player.play()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func showDetailButton(_ sender:UIButton) {
        delegate?.showDetail(withListing: listing)
    }
    
}
