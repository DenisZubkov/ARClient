//
//  LoadViewController.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 01.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController, UITextFieldDelegate {
    
    var currentUser: User! {
        didSet {
            print("OLD:\(oldValue?.username ?? "пусто") NEW:\(currentUser?.username ?? "пусто")")
        }
    }
    
    let gs = GlobalSettings()
    let dataProvider = DataProvider()
    var users: [User] = []
    var objects: [Object] = []
    let store = CoreDataStack.store
    var loadObjects: [LoadObject] = []
    var isAuth = false
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIElements(hide: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let url = gs.getUrlComponents(path: gs.checkPath).url else {
            showMessage(title: "Network error", message: "Can't connect to server")
            return
        }
        dataProvider.check(url: url) { (string) in
            if string == "Ok" {
                let savedUser = self.checkSavedUser()
                if savedUser.username != nil && savedUser.password != nil {
                    self.authorize(user: savedUser)
                } else {
                    self.UIElements(hide: false)
                    self.textFieldSetup()
                    self.buttonSetup()
                }
            } else {
                DispatchQueue.main.async {
                    self.showMessage(title: "Ошибка сети", message: string ?? "Нет соединения с сервером")
                }
            }
        }
    }
    
    
    
    //MARK: - TextFields work
    
    func UIElements(hide: Bool) {
        userTextField.isHidden = hide
        loginButton.isHidden = hide
        passwordTextField.isHidden = hide
        cancelButton.isHidden = hide
    }
    
    func textFieldSetup() {
        userTextField.delegate = self
        passwordTextField.delegate = self
        addTapGestureToHideKeyboard()
    }
    
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapGesture() {
        if userTextField.isEditing {
           userTextField.resignFirstResponder()
        }
        if passwordTextField.isEditing {
            passwordTextField.resignFirstResponder()
        }
    }
    
    // проверка правильности ввода значения в текстовые поля
    
    func checkTextField (textField: UITextField) ->  Bool {
        guard textField.text?.isEmpty == false else {
            let alert = UIAlertController(title: "Пустое значение поля",
                                          message: "Введите значение",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                textField.text = nil
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    // проверяем поле на корректность при окончании редактирования поля
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return checkTextField(textField: textField)
    }
    
    // проверяем поле на корректность при нажатии кнопки Done на клавиатуре
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if checkTextField(textField: textField) {
            if textField.tag == 0 {
                passwordTextField.becomeFirstResponder()
            } else if textField.tag == 1 {
                loginButtonPressed(loginButton)
            }
        }
        return false
    }
    
    func buttonSetup() {
        loginButton.tintColor = gs.buttonOkTextColor
        loginButton.backgroundColor = gs.buttonOkBgColor
        loginButton.layer.cornerRadius = CGFloat(gs.buttonCornerRadius)
        cancelButton.tintColor = gs.buttonCancelTextColor
        cancelButton.backgroundColor = gs.buttonCancelBgColor
        cancelButton.layer.cornerRadius = CGFloat(gs.buttonCornerRadius)
    }
    
    func checkSavedUser() -> User {
        // Проверка наличия сохраненного пользователя
        
        var user = User()
        if let username = UserDefaults.standard.value(forKey: "USERNAME") as? String,
            let password = UserDefaults.standard.value(forKey: "PASSWORD") as? String {
            user.username = username
            user.password = password
        }
        return user
    }
    
    func saveUser(user: User) {
        // Сохранение пользователя в UserDefault
        
        UserDefaults.standard.set(user.username, forKey: "USERNAME")
        UserDefaults.standard.set(user.password, forKey: "PASSWORD")

        return
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
        dataProvider.login = currentUser.username
        dataProvider.password = currentUser.password
        dataProvider.runRequest(method: .get, url: url, body: nil) { data in
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
    
    //MARK: - User CRUD
    
    func getUsersFromWeb(tableView: UITableView?) {
        let urlComponent = gs.getUrlComponents(path: "/users/all")
        guard let url = urlComponent.url else { return }
        dataProvider.login = self.currentUser.username
        dataProvider.password = self.currentUser.password
        dataProvider.runRequest(method: .get, url: url, body: nil) { data in
            guard let data = data else { return }
            //UserDefaults.standard.set(data, forKey: url.absoluteString)
            let usersJSON: [User]? = self.getJSONArray(from: data)
            guard let users = usersJSON else { return }
            self.users = users
            if tableView != nil {
                tableView?.reloadData()
            } else {
                self.currentUser = users.filter({$0.username == self.checkSavedUser().username}).first
            }
        }
    }
    
    func postUserToWeb(user: User) {
        let urlComponent = gs.getUrlComponents(path: "/user")
        guard let url = urlComponent.url else { return }
        dataProvider.login = currentUser.username
        dataProvider.password = currentUser.password
        guard let body = putJSONData(from: user) else { return }
        dataProvider.runRequest(method: .post, url: url, body: body) { data in
            guard let data = data else { return }
            print("Response: \(String(data: data, encoding: .utf8) ?? "")")
        }
    }
    
    func putUserToWeb(user: User) {
        guard let id = user.id else { return }
        let urlComponent = gs.getUrlComponents(path: "/user/\(id)")
        guard let url = urlComponent.url else { return }
        dataProvider.login = currentUser.username
        dataProvider.password = currentUser.password
        guard let body = putJSONData(from: user) else { return }
        dataProvider.runRequest(method: .put, url: url, body: body) { data in
            guard let data = data else { return }
            print("Response: \(String(data: data, encoding: .utf8) ?? "")")
        }
    }
    
    func deleteUserToWeb(user: User) {
        guard let id = user.id else { return }
        let urlComponent = gs.getUrlComponents(path: "/user/\(id)")
        guard let url = urlComponent.url else { return }
        dataProvider.login = currentUser.username
        dataProvider.password = currentUser.password
        dataProvider.runRequest(method: .delete, url: url, body: nil) { data in
            guard let data = data else { return }
            print("Response: \(String(data: data, encoding: .utf8) ?? "")")
        }
    }
    
    func authorize(user: User) {
        dataProvider.login = user.username
        dataProvider.password = user.password
        guard let url = gs.getUrlComponents(path: gs.authPath).url else {
            showMessage(title: "Network error", message: "Can't connect to server")
            return
        }
        dataProvider.runRequest(method: .get, url: url, body: nil) { data in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showMessage(title: "Вход в приложение", message: "Неверные логин или пароль")
                    self.UIElements(hide: false)
                    self.textFieldSetup()
                    self.buttonSetup()
                }
                return
            }
            let objectsJSON: [Object]? = self.getJSONArray(from: data)
            
            guard let _ = objectsJSON else {
                DispatchQueue.main.async {
                    self.showMessage(title: "Вход в приложение", message: "Неверные логин или пароль")
                    self.UIElements(hide: false)
                    self.textFieldSetup()
                    self.buttonSetup()
                }
                return
            }
            self.store.fetchLoadObjects()
            self.loadObjects = self.store.fetchedLoadObjects
            //self.appSetup()
            self.saveUser(user: user)
            self.currentUser = user
            self.getUsersFromWeb(tableView: nil)
            
            self.performSegue(withIdentifier: "mainSegue", sender: nil)
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
    
    func putJSONData<T : Codable>(from jsonObject: T) -> Data? {
        let encoder = JSONEncoder()
        guard let httpBody = try? encoder.encode(jsonObject) else { return nil }
        return httpBody
    }
    
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let username = userTextField.text, let password = passwordTextField.text {
            var user = User()
            user.username = username
            user.password = password
            authorize(user: user)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func returnFromSettings(unwindSegue: UIStoryboardSegue) {
    }
}
