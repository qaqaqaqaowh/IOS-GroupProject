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
        playerController = AVPlayerViewController()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        videoView.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    @objc func imageViewTapped() {
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .savedPhotosAlbum
        cameraController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        cameraController.allowsEditing = false
        cameraController.delegate = self
        present(cameraController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadButton(_ sender: UIButton) {
        guard let url = mediaURL,
        let currentUserUID = Auth.auth().currentUser?.uid else {return}
        let key = self.ref.child("listings").childByAutoId()
        key.setValue(["owner":currentUserUID,"viewCount":0])
        storageRef.child("videos").child(key.key).putFile(from: url, metadata: nil) { (metadata, error) in
            guard let downloadURL = metadata?.downloadURL() else {return}
            key.updateChildValues(["videoURL":downloadURL.absoluteString])
            let alert = UIAlertController(title: "Done", message: "Done", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
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
        playerController.view.frame = videoView.bounds
        videoView.addSubview(playerController.view)
        player.play()
    }
}