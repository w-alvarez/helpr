//
//  MyTabBarViewController.swift
//  helpr
//
//  Created by walter.alvarez on 2018-10-30.
//  Copyright © 2018 ryan.konynenbelt. All rights reserved.
//

import UIKit

class MyTabBarViewController: UITabBarController {

    let selectedIcons: [String] = ["homeENBL", "jobsENBL", "postENBL", "mypostsENBL", "accountENBL"]
    let unselectedIcons: [String] = ["home", "jobs", "post", "myposts", "account"]
    
    var database = DatabaseHelper()
    var storage = StorageHelper()
    var picRef = String()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        getCurrentProfile()
        
        // Do any additional setup after loading the view.
//        if let count = self.tabBar.items?.count {
//            for i in 0...(count-1) {
//                let selectedImgName   = selectedIcons[i]
//                let unselectedImgName = unselectedIcons[i]
//
//                self.tabBar.items?[i].selectedImage = UIImage(named: selectedImgName)?.withRenderingMode(.alwaysOriginal)
//                self.tabBar.items?[i].image = UIImage(named: unselectedImgName)?.withRenderingMode(.alwaysOriginal)
//            }
//        }
        
        //let selectedColor   = UIColor.white
        //let unselectedColor = UIColor.white
        
        //UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: unselectedColor], for: .normal)
        //UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor], for: .selected)
    }
    
//    func getCurrentProfile() {
//        database.getUser() { (user) -> () in
//            UserProfile.name = user!.name
//            UserProfile.email = user!.email
//            UserProfile.skills = user!.skills
//            self.storage.loadProfilePicture(picRef: user!.picRef){ image in
//                UserProfile.profilePic = image
//            }
//        }
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}