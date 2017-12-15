//
//  pickerNav.swift
//  IOSGroupProject
//
//  Created by Jacob Schantz on 12/15/17.
//
//  ViewController.swift
//  pickerView
//
//  Created by Jacob Schantz on 12/13/17.
//  Copyright © 2017 Jake Schantz. All rights reserved.
//

import UIKit

extension ListingsViewController {
    
    
    func createPickerView(){
        pickerView.frame = view.frame
        pickerView.alpha = 0.0
        effectView.contentView.addSubview(pickerView)
    }
    
    
    func createBlurView(){
        view.addSubview(effectView)
        createPickerView()
        effectView.frame = view.frame
        self.effectView.effect = nil
        self.effectView.isHidden = true
    }
    
    
    func blurView(){
        if !effectView.isHidden {
            UIView.animate(withDuration: 0.5, animations: {
                self.effectView.effect = nil
                self.pickerView.alpha = 0.0
                self.navigationItem.leftBarButtonItem?.image = UIImage(named: "switch")
            }, completion: { (bool) in
                self.effectView.isHidden = true
            })
        }
        else {
            self.effectView.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.effectView.effect = UIBlurEffect(style: .dark)
                self.pickerView.alpha = 1.0
                self.navigationItem.leftBarButtonItem?.image = UIImage(named: "x")
            }, completion: { (bool) in
                print("nil")
            })
        }
    }
    
    
    func navigationStyle(){
        navigationController?.tabBarController?.tabBar.isTranslucent = false
        navigationController?.tabBarController?.tabBar.isOpaque = true
        navigationController?.tabBarController?.tabBar.tintColor = UIColor.white
        navigationController?.tabBarController?.tabBar.barTintColor = UIColor(red: 255/255, green: 70/255, blue: 80/255, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 70/255, blue: 80/255, alpha: 1)
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
    
    
    func createNewListingButton(){
        let button = UIBarButtonItem(title: "New", style: .done, target: self, action: #selector(newListingButtonTapped))
        navigationItem.rightBarButtonItem = button
    }
    @objc func newListingButtonTapped(){
        let vc = UploadVideoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func createSwitchButton(){
        let image = UIImage(named: "switch")
        let imageButton = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(switchButtonTapped))
        navigationItem.leftBarButtonItem = imageButton
    }
    @objc func switchButtonTapped() {
        pickerView.isUserInteractionEnabled = true
        blurView()
    }
    
    func createPickerNav(){
        navigationStyle()
        createNavTitle("Find Properties")
        createBlurView()
        createSwitchButton()
        createNewListingButton()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
    }
    
}



extension ListingsViewController : UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return view.frame.height/5
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return createOptionsLabel(options[row])
    }
}



extension ListingsViewController : UIPickerViewDelegate {
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        createNavTitle(options[row])
        pickerView.isUserInteractionEnabled = false
        blurView()
    }
}

