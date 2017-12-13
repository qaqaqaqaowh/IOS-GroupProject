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
    
    @IBOutlet weak var videoView: UIView!
    
    let storageRef = Storage.storage().reference()
    
    let ref = Database.database().reference()
    
    var mediaURL: URL?
    
    var player: AVPlayer! = nil
    
    var playerController: AVPlayerViewController! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        videoView.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    @objc func imageViewTapped() {
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController.allowsEditing = false
        cameraController.delegate = self
        present(cameraController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadButton(_ sender: UIButton) {
        guard let url = mediaURL else {return}
        storageRef.child("videos").putFile(from: url, metadata: nil) { (metadata, error) in
            guard let downloadURL = metadata?.downloadURL(),
                let currentUserUID = Auth.auth().currentUser?.uid else {return}
            self.ref.child("listings").childByAutoId().setValue(["owner":currentUserUID,"videoURL":downloadURL.absoluteString,"viewCount":0])
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UploadVideoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        mediaURL = (info[UIImagePickerControllerMediaURL] as! URL)
        dismiss(animated: true, completion: nil)
        player = AVPlayer(url: mediaURL!)
        playerController.player = player
        playerController.view.bounds = videoView.frame
        videoView.addSubview(playerController.view)
        player.play()
    }
}
