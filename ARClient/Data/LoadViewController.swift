//
//  LoadViewController.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 01.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {
    
    var currentUser: User!
    var currentToken: Token?
    let gs = GlobalSettings()
    let dataProvider = DataProvider()
    var users: [User] = []
    var objects: [Object] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mainUser()
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ru.denzu.ARClient.objects")!
        do {
            let fileUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)

            for item in fileUrls {
                if item.pathExtension == "usdz" {
                    print("Found \(try item.resourceValues(forKeys: [URLResourceKey.creationDateKey]))")
                }
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
        appSetup()
    }
    
    func appSetup() {
        guard let url = gs.getUrlComponents(path: gs.checkPath).url else {
            showMessage(title: "Network error", message: "Can't connect to server")
            return
        }
        
        dataProvider.check(url: url) { (string) in
            if string == "Ok" {
                self.currentUser = self.checkSavedUser()
                if let user = self.currentUser {
                    if self.checkOnServer(user: user) {
                        print("CAN WORK USER \(user.username ?? "incoginto")")
                        self.performSegue(withIdentifier: "mainSegue", sender: nil)
                    }
                } else {
                    print("SING IN INCOGNITO!")
                    self.performSegue(withIdentifier: "mainSegue", sender: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.showMessage(title: "Ошибка сети", message: string ?? "Нет соединения с сервером")
                }
            }
        }
    }
    
    func checkSavedUser() -> User {
        // Проверка наличия сохраненного пользователя
        
        var user = User()
        if  let id = UserDefaults.standard.value(forKey: "USERID") as? Int,
            let username = UserDefaults.standard.value(forKey: "USERNAME") as? String,
            let password = UserDefaults.standard.value(forKey: "PASSWORD") as? String {
            user.id = id
            user.username = username
            user.password = password
        }
        return user
    }
    
    func saveUser(user: User) {
        // Сохранение пользователя в UserDefault
        
        UserDefaults.standard.set(user.id, forKey: "USERID")
        UserDefaults.standard.set(user.username, forKey: "USERNAME")
        UserDefaults.standard.set(user.password, forKey: "PASSWORD")
        return
    }
    
    func mainUser() {
        // Сохранение пользователя в UserDefault
        UserDefaults.standard.set(0, forKey: "USERID")
        UserDefaults.standard.set("Admin", forKey: "USERNAME")
        UserDefaults.standard.set("Admin", forKey: "PASSWORD")
        return
    }
    
    
    func checkOnServer(user: User) -> Bool {
        // ToDo - проверка права на соединение данного пользователя
        return true
    }
    
    func showMessage(title: String, message: String) {
        let alertData = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            DispatchQueue.main.async {
                //performSegue(withIdentifier: "MainSegue", sender: nil)
            }
        }
        alertData.addAction(cancelAction)
        present(alertData, animated: true, completion: nil)
    }
    
    func loadObjectsFromWbeb(tableView: UITableView?) {
        let urlComponent = gs.getUrlComponents(path: "/objects/all")
        guard let url = urlComponent.url else { return }
        dataProvider.downloadData(url: url) { data in
            guard let data = data else { return }
            //UserDefaults.standard.set(data, forKey: url.absoluteString)
            let objectsJSON: [Object]? = self.getJSONArray(from: data)
            guard let objects = objectsJSON else { return }
            self.objects = objects
            if tableView != nil {
                tableView?.reloadData()
            }
        }
    }
    
    
    //MARK: JSON = decodable
    
    func getJSONObject<T : Decodable>(from data: Data) -> T? {
        if let dataString = String(data: data, encoding: .utf8) {
            let jsonData = Data(dataString.utf8)
            do {
                let jsonObject = try JSONDecoder().decode(T.self, from: jsonData)
                return jsonObject
                
            } catch let error as NSError {
                print(error.localizedDescription)
                print(dataString)
                return nil
            }
        }
        return nil
    }
    
    func getJSONArray<T : Decodable>(from data: Data) -> [T]? {
        if let dataString = String(data: data, encoding: .utf8) {
            let jsonData = Data(dataString.utf8)
            do {
                let jsonObject = try JSONDecoder().decode([T].self, from: jsonData)
                return jsonObject
                
            } catch let error as NSError {
                print(error.localizedDescription)
                print(dataString)
                return nil
            }
        }
        return nil
    }
    
}
