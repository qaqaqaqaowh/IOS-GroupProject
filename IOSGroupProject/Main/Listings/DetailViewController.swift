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
import FirebaseStorage

class DetailViewController: UIViewController {
    
    
    var tap : UITapGestureRecognizer!
    var dictionary : [String : String] = ["Location" : "Location", "Price" : "Price", "Bedrooms" : "Bedrooms", "Square ft." : "Square ft.", "Email" : "email@email.com"]
    var features : [String] = ["Location", "Price", "Bedrooms", "Square ft.", "Email"]
    var selectedListing : Listing = Listing()
    var navTitle : UILabel = UILabel()
    var mediaURL: URL?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    let pageControl : UIPageControl = UIPageControl()
    
    
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
    }
    @objc func saveButtonTapped(){

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
        for feature in features {
            if dictionary[feature] == feature || dictionary[feature] == "" {
                let alert = UIAlertController(title: "Error", message: "You must specify \(feature)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    
    func uploadListing(){
        let ref = Database.database().reference()
        selectedListing.listingId = ref.child("listings").childByAutoId().key
        guard let currentUser = Auth.auth().currentUser?.uid
            else{return}
        self.selectedListing.price = self.dictionary["Price"]!
        self.selectedListing.owner = currentUser
        self.selectedListing.latitude = self.dictionary["Location"]!
        self.selectedListing.longitude = self.dictionary["Location"]!
        self.selectedListing.bedrooms = self.dictionary["Bedrooms"]!
        self.selectedListing.squareFt = self.dictionary["Square ft."]!
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
            createSaveButton()
        case .saved:
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = dictionary[features[indexPath.row]]
            if true {
                cell.imageView?.image = UIImage(named: "true")
            } else {
                cell.imageView?.image = UIImage(named: "false")
            }
            if self.isEditing {
                cell.textLabel?.textColor = UIColor.blue
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
            if indexPath.row < features.count-1{
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
            textField.text = value
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
