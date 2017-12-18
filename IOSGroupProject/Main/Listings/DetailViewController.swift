//
//  DetailViewController.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/12/17.
//  Copyright © 2017 asd. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    
    var imageArray : [String] = ["house1", "house2"]
    let criteraArray : [String] = ["Location", "Price", "Bedrooms", "Square ft."]
    var criteria : [String : String] = ["Location" : "Location", "Price" : "", "Bedrooms" : "", "Square ft." : ""]
    let criteriaBool : [String : Bool] = ["Location" : false, "Price" : false, "Bedrooms" : false, "Square ft." : false]
    var isCurrentUserListing : Bool = true
    var canEditItems : Bool = false
    var navTitle : UILabel = UILabel()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    let pageControl : UIPageControl = UIPageControl()

    
    func createPageControll(){
        if imageArray.count > 1 {
            pageControl.removeFromSuperview()
            pageControl.isUserInteractionEnabled = false
            let scrollViewHeight: CGFloat = 35
            pageControl.frame = CGRect(x: scrollView.frame.width/2 , y: scrollView.frame.height-scrollViewHeight, width: scrollView.frame.width, height: scrollViewHeight)
            pageControl.center = CGPoint(x: view.center.x, y: pageControl.center.y)
            pageControl.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.3)
            pageControl.numberOfPages = imageArray.count
            view.addSubview(pageControl)
        }
    }
    
    
    func addItemsToScrollView() {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        let scrollViewWidth: CGFloat = self.scrollView.frame.width
        let scrollViewHeight :CGFloat = self.scrollView.frame.height
        for i in 0..<imageArray.count {
            let newImageView = UIImageView(frame: CGRect(x: CGFloat(i)*scrollViewWidth, y:0, width: scrollViewWidth, height: scrollViewHeight ))
            newImageView.image = UIImage(named: imageArray[i])
            if imageArray[i] == "tap" {
                newImageView.contentMode = .center
            }
            scrollView.addSubview(newImageView)
        }
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * CGFloat(imageArray.count), height: self.scrollView.frame.height)
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
    
    
    func createEditButton(){
        let button = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = button
    }
    @objc func editButtonTapped(){
        if canEditItems {
            navigationItem.rightBarButtonItem?.title = "Edit"
            imageArray.remove(at: 0)
            addItemsToScrollView()
            tableView.reloadData()
        }
        else {
            navigationItem.rightBarButtonItem?.title = "Finish"
            imageArray.insert("tap", at: 0)
            addItemsToScrollView()
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
            pageControl.currentPage = 0
            tableView.reloadData()
        }
        canEditItems = !canEditItems
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        createNavTitle("House")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelectionDuringEditing = true
        if !isCurrentUserListing {
            createSaveButton()
        }
        else {
            createEditButton()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        addItemsToScrollView()
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
        return criteria.count+1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < criteraArray.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = criteraArray[indexPath.row]
            if criteriaBool[criteraArray[indexPath.row]]!{
                cell.imageView?.image = UIImage(named: "true")
            } else {
                cell.imageView?.image = UIImage(named: "false")
            }
            if self.canEditItems {
                cell.textLabel?.textColor = UIColor.blue
            }
            return cell
        }
        else {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "PhoneCell")
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PhoneCell")
            cell.textLabel?.text = "Email:"
            cell.detailTextLabel?.text = "billy@billyGoat.com"
            cell.imageView?.image = UIImage(named: "email")
            if self.canEditItems {
                cell.detailTextLabel?.textColor = UIColor.blue
            }
            return cell
        }
    }
}

extension DetailViewController : UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if canEditItems {
            if indexPath.row < criteraArray.count{
                let key = criteraArray[indexPath.row]
                guard let value = criteria[key]
                    else {return}
                editCritera(key, value)
            }
        }
    }
    
    
    func editCritera(_ key: String, _ value: String) {
        let alertController = UIAlertController(title: key, message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let inputTextField = alertController.textFields![0] as UITextField
            if inputTextField.text != "" {
                guard let name =  inputTextField.text
                    else{ return }
                self.criteria[key] = name
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
