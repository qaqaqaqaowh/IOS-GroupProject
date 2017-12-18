//
//  Extensions.swift
//  FirebaseChatApp
//
//  Created by Jacob Schantz on 11/4/17.
//  Copyright © 2017 Jacob Schantz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import MapKit

extension UIViewController {
    
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func requireLogin() {
        if Auth.auth().currentUser == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
            navigationController?.viewControllers = [vc!]
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
        navigationStyle()
        let label = UILabel()
        label.text = inputText
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont(name: "EBGaramond-Regular", size: 22.0)
        label.attributedText = addLetterSpacing(label.text!)
        return label
    }
    
    func isDistanceInRange(long1:String, lat1:String, long2:String, lat2:String, range:String) -> Bool {
        guard let rng = Double(range),
        let lng1 = Double(long1),
        let lng2 = Double(long2),
        let lt1 = Double(lat1),
            let lt2 = Double(lat2) else {return false}
        let location1 = CLLocation(latitude: lt1, longitude: lng1)
        let location2 = CLLocation(latitude: lt2, longitude: lng2)
        let distance = location1.distance(from: location2)
        if rng >= distance {
            return true
        }
        return false
    }
}

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    func loadImageUsingCache(withUrl urlString: String) {
        guard let url = URL(string: urlString)
            else{return}
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let validError = error {
                print("Download Image Error : \(validError.localizedDescription)")
                return
            }
            if let image = UIImage(data: data!) {
                DispatchQueue.main.async {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                }
            }
        }
        task.resume()
    }
}

