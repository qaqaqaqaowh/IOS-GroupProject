//
//  UploadVideoViewController.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/13/17.
//  Copyright © 2017 asd. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import MobileCoreServices
import AVKit
import AVFoundation


class UploadVideoViewController: UIViewController {
    
    
    var videoView: UIView = UIView()
    var placeHolder: UIImageView = UIImageView()
    var navTitle : UILabel = UILabel()
    var mediaURL: URL?
    var player: AVPlayer! = nil
    var playerController: AVPlayerViewController! = nil
    
    
    func createPlaceHolder(){
        placeHolder.contentMode = .scaleAspectFit
        placeHolder.image = UIImage(named: "tap")
        placeHolder.frame = CGRect(x: 0, y: 0, width: view.frame.width/2, height: view.frame.height/2)
        placeHolder.center = videoView.center
        videoView.addSubview(placeHolder)
    }
    
    
    func createVideoView(){
        videoView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height-64-49)
        let tap = UITapGestureRecognizer(target: self, action: #selector(videoViewTapped))
        videoView.addGestureRecognizer(tap)
        createPlaceHolder()
        view.addSubview(videoView)
    }
    @objc func videoViewTapped() {
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .savedPhotosAlbum
        cameraController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        cameraController.allowsEditing = false
        cameraController.delegate = self
        present(cameraController, animated: true, completion: nil)
    }
    
    
    func createNextButton(){
        let button = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextButtonTapped))
        navigationItem.rightBarButtonItem = button
    }
    @objc func nextButtonTapped(){
        if let _ = mediaURL {
            let newListing = Listing()
            newListing.status = .new
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            vc.mediaURL = mediaURL
            vc.selectedListing = newListing
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "You must upload a video", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func createNavTitle(_ title: String){
        navTitle = createOptionsLabel(title)
        navTitle.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        self.navigationItem.titleView = navTitle
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createNavTitle("Upload Video")
        createNextButton()
        createVideoView()
        view.backgroundColor = UIColor.white
        playerController = AVPlayerViewController()
    }
}



extension UploadVideoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let infoURL = info[UIImagePickerControllerMediaURL] as? URL
            else {return}
        mediaURL = infoURL
        dismiss(animated: true, completion: nil)
        player = AVPlayer(url: mediaURL!)
        playerController.player = player
        playerController.view.frame = videoView.bounds
        placeHolder.removeFromSuperview()
        videoView.addSubview(playerController.view)
    }
}
