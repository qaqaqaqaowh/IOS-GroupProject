//
//  DetailViewController.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/12/17.
//  Copyright © 2017 asd. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    
    let pickerView : UIPickerView = UIPickerView()
    let pictures : [String] = ["house1","house2","house3","house4"]
    let effectView : UIVisualEffectView = UIVisualEffectView()
    var navTitle : UILabel = UILabel()
    
    
    func createPickerView(){
        pickerView.frame = CGRect(x: 0, y: -36, width: view.frame.width, height: (view.frame.height*9)/10)
        pickerView.selectRow(1, inComponent: 0, animated: true)
        view.addSubview(pickerView)
    }
    
    
    func createImageView(_ imageName: String) ->  UIImageView {
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.height*6)/10)
        return imageView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerView()
        //        self.view.backgroundColor = .white
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
    }
}



extension DetailViewController : UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pictures.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return (view.frame.height*6)/10
    }
}


extension DetailViewController : UIPickerViewDelegate {
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return createImageView(pictures[row])
    }
}
