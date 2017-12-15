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
    let storageRef = Storage.storage().reference()
    let ref = Database.database().reference()
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
            uploadVideo()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "You must upload a video", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func addLetterSpacing(_ inputString: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: inputString)
        attributedString.addAttribute(NSKernAttributeName, value: 2.0, range: NSMakeRange(0, attributedString.length-1))
        return attributedString
    }
    
    
    func createOptionsLabel(_ inputText: String) -> UILabel {
        let label = UILabel()
        label.text = inputText
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont(name: "EBGaramond-Regular", size: 22.0)
        label.attributedText = addLetterSpacing(label.text!)
        return label
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
    
    
    
    func uploadVideo() {
        guard let url = mediaURL,
        let currentUserUID = Auth.auth().currentUser?.uid
            else {return}
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumb = UIImage(cgImage: cgImage)
            let data = UIImageJPEGRepresentation(thumb, 1)
            
            let key = self.ref.child("listings").childByAutoId()
            key.setValue(["owner":currentUserUID,"name" : "text"])
            storageRef.child("videos").child(key.key).putFile(from: url, metadata: nil) { (metadata, error) in
                guard let downloadURL = metadata?.downloadURL() else {return}
                key.updateChildValues(["videoURL":downloadURL.absoluteString])
                guard let validData = data else {return}
                self.storageRef.child("images").child(key.key).putData(validData, metadata: nil, completion: { (metadata, error) in
                    guard let thumbURL = metadata?.downloadURL() else {return}
                    key.updateChildValues(["thumb":thumbURL.absoluteString])
                    let alert = UIAlertController(title: "Video Finished Uploading", message: "", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                })
            }
        } catch {
            
        }
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
        player.play()
    }
}
