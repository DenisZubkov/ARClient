//
//  SettingsViewController.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 09.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    let gs = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    let dataProvider = DataProvider()

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if rootViewController.currentUser == nil {
            userLabel.text = "Вход не выполнен"
            loginButton.setTitle("Войти", for: .normal)
        } else {
            userLabel.text = rootViewController.currentUser?.username
            loginButton.setTitle("Выйти", for: .normal)
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if rootViewController.currentUser == nil {
            self.performSegue(withIdentifier: "ReturnFromSettingsUnwind", sender: nil)
        } else {
            rootViewController.currentUser = nil
            loginButton.setTitle("Войти", for: .normal)
            userLabel.text = "Вход не выполнен"
//            UserDefaults.standard.removeObject(forKey: "USERNAME")
            UserDefaults.standard.removeObject(forKey: "PASSWORD")
            rootViewController.tabbarSetup(user: nil, tbc: tabBarController)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
