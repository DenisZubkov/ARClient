//
//  UsersListViewController.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 02.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit

class UsersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let gs = GlobalSettings()
       let rootViewController = AppDelegate.shared.rootViewController
       let dataProvider = DataProvider()

    
    @IBOutlet weak var usersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        rootViewController.getUsersFromWeb(tableView: usersTableView)
        rootViewController.loadObjectsFromWbeb(tableView: usersTableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rootViewController.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UsersListTableViewCell
        let user = rootViewController.users[indexPath.row]
        cell.userLabel.text = user.username
        cell.passwordLabel.text = user.password
        cell.saltLabel.text = user.salt
        cell.isAdminSwitch.isOn = user.isadmin == 1 ? true : false
        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditUserSegue" {
            if let indexPath = usersTableView.indexPathForSelectedRow {
                let user = rootViewController.users[indexPath.row]
                let dvc = segue.destination as! UserDetailViewController
                dvc.user = user
            }
        }
    }
    
    @IBAction func returnFromEdit(unwindSegue: UIStoryboardSegue) {
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
