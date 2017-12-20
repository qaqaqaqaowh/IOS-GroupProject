//
//  DetailViewController.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/12/17.
//  Copyright © 2017 asd. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit
import FirebaseStorage

class DetailViewController: UIViewController {
    
    
    var tap : UITapGestureRecognizer!
    var dictionary : [String : Any] = ["Location" : CLLocationCoordinate2D(), "Price" : "Price", "Bedrooms" : "Bedrooms", "Square ft." : "Square ft.", "Email" : "email@email.com"]
    var features : [String] = ["Location", "Price", "Bedrooms", "Square ft.", "Email"]
    var selectedListing : Listing = Listing()
    var navTitle : UILabel = UILabel()
    var mediaURL: URL?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    let pageControl : UIPageControl = UIPageControl()
    
    
    func grabCurrentSettings() {
        dictionary["Location"] = selectedListing.location
        dictionary["Price"] = selectedListing.price
        dictionary["Bedrooms"] = selectedListing.bedrooms
        dictionary["Square ft."] = selectedListing.squareFt
        tableView.reloadData()
    }
    
    
    func createPageControll(){
        if selectedListing.images.count > 1 {
            pageControl.removeFromSuperview()
            pageControl.isUserInteractionEnabled = false
            let scrollViewHeight: CGFloat = 35
            pageControl.frame = CGRect(x: scrollView.frame.width/2 , y: scrollView.frame.height-scrollViewHeight, width: scrollView.frame.width, height: scrollViewHeight)
            pageControl.center = CGPoint(x: view.center.x, y: pageControl.center.y)
            pageControl.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.3)
            pageControl.numberOfPages = selectedListing.images.count
            view.addSubview(pageControl)
        }
    }
    func addItemsToScrollView() {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        let scrollViewWidth: CGFloat = self.scrollView.frame.width
        let scrollViewHeight :CGFloat = self.scrollView.frame.height
        for i in 0..<selectedListing.images.count {
            let newImageView = UIImageView(frame: CGRect(x: CGFloat(i)*scrollViewWidth, y:0, width: scrollViewWidth, height: scrollViewHeight ))
            newImageView.image = selectedListing.images[i]
            if selectedListing.images[i] == UIImage(named: "tap") {
                newImageView.contentMode = .center
                tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
                newImageView.addGestureRecognizer(tap)
                newImageView.isUserInteractionEnabled = true
            }
            scrollView.addSubview(newImageView)
        }
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * CGFloat(selectedListing.images.count), height: self.scrollView.frame.height)
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        self.scrollView.delegate = self
        createPageControll()
    }
    func createNavTitle(_ title: String){
        navTitle = createOptionsLabel(title)
        navTitle.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        self.navigationItem.titleView = navTitle
    }
    
    
    func createSaveButton(){
        let button = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = button
        if selectedListing.status == .saved {
            navigationItem.rightBarButtonItem?.title = "Save"
        }
        else{
            navigationItem.rightBarButtonItem?.title = "Save"
        }
    }
    @objc func saveButtonTapped(){
        if selectedListing.status == .saved {
            unSaveListing()
            navigationItem.rightBarButtonItem?.title = "Save"
            selectedListing.status = .other
        }
        else{
            saveListing()
            navigationItem.rightBarButtonItem?.title = "Unsave"
            selectedListing.status = .saved
        }
    }
    
    func unSaveListing(){
        let savedRef = Database.database().reference().child("users").child(CurrentUser.uid).child("saved")
        savedRef.child(selectedListing.listingId).removeValue()
    }
    
    func saveListing(){
        let savedRef = Database.database().reference().child("users").child(CurrentUser.uid).child("saved")
        savedRef.updateChildValues([selectedListing.listingId : true])
    }
    
    
    
    
    func createRightButton(){
        var button = UIBarButtonItem()
        if isEditing {
            button = UIBarButtonItem(title: "Finish", style: .done, target: self, action: #selector(rightButtonTapped))
        }
        else {
            button = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(rightButtonTapped))
        }
        navigationItem.rightBarButtonItem = button
    }
    @objc func rightButtonTapped(){
        if isEditing{
            if ensureInput() {
                selectedListing.images.remove(at: 0)
                uploadListing()
                finish()
            }
        }
        else {
            startEditing()
        }
    }
    
    
    func ensureInput() -> Bool{
        if selectedListing.images.count == 1 {
            let alert = UIAlertController(title: "Error", message: "You must upload images", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        for i in 0..<features.count {
            if i != 0 {
                if dictionary[features[i]] as! String == features[i] || dictionary[features[i]] as! String == "" {
                    let alert = UIAlertController(title: "Error", message: "You must specify \(features[i])", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    return false
                }
            }
            else {
                guard let coordinate = dictionary[features[i]] as? CLLocationCoordinate2D
                    else{return false}
                let placeHolderCoordinate = CLLocationCoordinate2DMake(0.0, 0.0)
                if coordinate.longitude == placeHolderCoordinate.longitude && coordinate.longitude == placeHolderCoordinate.longitude{
                    let alert = UIAlertController(title: "Error", message: "You must specify Location)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        return true
    }
    
    
    func uploadListing(){
        let ref = Database.database().reference()
        selectedListing.listingId = ref.child("listings").childByAutoId().key
        guard let currentUser = Auth.auth().currentUser?.uid
            else{return}
        self.selectedListing.price = self.dictionary["Price"] as! String
        self.selectedListing.owner = currentUser
        self.selectedListing.location = self.dictionary["Location"] as! CLLocationCoordinate2D
        self.selectedListing.bedrooms = self.dictionary["Bedrooms"] as! String
        self.selectedListing.squareFt = self.dictionary["Square ft."] as! String
        uploadVideo {
            self.selectedListing.saveToDatabase()
        }
    }
    
    func finish() {
        guard let viewControllers = navigationController?.viewControllers
            else{return}
        for vc in viewControllers {
            if vc.isKind(of: ListingsViewController.self) {
                navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    
    func startEditing(){
        navigationItem.rightBarButtonItem?.title = "Finish"
        selectedListing.images.insert(UIImage(named: "tap")!, at: 0)
        addItemsToScrollView()
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        pageControl.currentPage = 0
        tableView.reloadData()
        isEditing = !isEditing
    }
    
    
    func uploadVideo(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        let ref = Database.database().reference()
        let listingID = ref.child("listings").childByAutoId().key
        let storageRef = Storage.storage().reference()
        guard let url = mediaURL
            else {return}
        group.enter()
        storageRef.child("videos").child(listingID).putFile(from: url, metadata: nil) { (metadata, error) in
            guard let videoURL = metadata?.downloadURL()
                else {return}
            self.selectedListing.videoURL = videoURL.absoluteString
            group.leave()
        }
        for i in 0..<selectedListing.images.count {
            group.enter()
            guard let validData = UIImagePNGRepresentation(selectedListing.images[i])
                else { return }
            let folder = listingID
            let imgRef = storageRef.child("images/\(folder)/\(i).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            imgRef.putData(validData, metadata: metadata, completion: { (metadata, error) in
                guard let imageURL = metadata?.downloadURL()
                    else {return}
                self.selectedListing.imageURLS.append(imageURL.absoluteString)
                group.leave()
            })
        }
        group.notify(queue: .main) {
            completion()
        }
    }

    
    func dealWithTypes(){
        switch selectedListing.status {
        case .new:
            startEditing()
            createRightButton()
        case .owned:
            createRightButton()
        case .other:
            grabCurrentSettings()
            createSaveButton()
        case .saved:
            grabCurrentSettings()
            createSaveButton()
        }
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        dealWithTypes()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelectionDuringEditing = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        addItemsToScrollView()
    }
    
    
    @objc func scrollViewTapped(_ gesture: UITapGestureRecognizer){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary),
            let mediaType = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            imagePicker.mediaTypes = mediaType
            present(imagePicker, animated: true, completion: nil)
        }
    }
}


extension DetailViewController : UIScrollViewDelegate {
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        self.pageControl.currentPage = Int(currentPage)
    }
}


extension DetailViewController : UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return features.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < features.count-1 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            cell.textLabel?.text = "\(features[indexPath.row]):"
            if indexPath.row != 0 {
                cell.detailTextLabel?.text = dictionary[features[indexPath.row]] as? String
            }
            else {
                guard let coordinate = dictionary[features[indexPath.row]] as? CLLocationCoordinate2D
                    else{return cell}
                cell.detailTextLabel?.text = String(coordinate.latitude)
            }
            if isEditing {
                cell.detailTextLabel?.textColor = UIColor.blue
            }
            else {
                cell.detailTextLabel?.textColor = UIColor.lightGray
            }
            return cell
        }
        else {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "emailCell")
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "emailCell")
            cell.textLabel?.text = "Email:"
            cell.detailTextLabel?.text = features[features.count-1]
            cell.imageView?.image = UIImage(named: "email")
            return cell
        }
    }
}

extension DetailViewController : UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            if indexPath.row == 0 {
                let vc = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                vc.delegate = self
                navigationController?.pushViewController(vc, animated: true)
            }
            else if indexPath.row < features.count{
                editCritera(indexPath.row)
            }
        }
    }
    
    
    func editCritera(_ place: Int ) {
        let key = features[place]
        let value = dictionary[key]
        let alertController = UIAlertController(title: key, message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let inputTextField = alertController.textFields![0] as UITextField
            if inputTextField.text != "" {
                guard let newValue =  inputTextField.text
                    else{ return }
                self.dictionary[key] = newValue
                self.tableView.reloadData()
            }
        }))
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = value as? String
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)
    }
}


extension DetailViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedListing.images.append(selectedImage)
            addItemsToScrollView()
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


extension DetailViewController: MapViewPassCoordDelegate {
    
    func passCoord(withLogitude: String, withLatitude: String) {
        guard let logitude = Double(withLogitude),
            let latitude = Double(withLogitude)
            else{return}
        dictionary["Location"] = CLLocationCoordinate2D(latitude: latitude, longitude: logitude)
        tableView.reloadData()
    }
}
