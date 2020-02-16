//
//  LoadViewController.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 01.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit
import QuickLookThumbnailing

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
    var initialTBCViewControllers: [UIViewController]?
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    
    
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
    
    func getFileFromWeb(object: Object, completion: @escaping (Data?, Data?) -> Void) {
        guard let filename = object.internalFilename else {
            completion(nil, nil)
            return
        }
        let urlComponent = gs.getUrlComponents(path: "/file/\(filename)")
        guard let url = urlComponent.url else {
            completion(nil, nil)
            return
        }
        dataProvider.login = currentUser.username
        dataProvider.password = currentUser.password
        dataProvider.runRequest(method: .get, url: url, body: nil) { data in
            guard let data = data else {
                completion(nil, nil)
                return
            }
            //UserDefaults.standard.set(data, forKey: url.absoluteString)
            let objectFileJSON: ObjectFile? = self.getJSONObject(from: data)
            guard let objectFile = objectFileJSON, let fileData = objectFile.fileData, let thumbnailData = objectFile.thumbnailData, let filename = object.internalFilename else {
                completion(nil, nil)
                return
            }
            if self.dataProvider.saveDataToFile(fileName:  filename, fileExt: "usdz", data: fileData),
                self.dataProvider.saveDataToFile(fileName:  filename, fileExt: "png", data: fileData)  {
                completion(fileData, thumbnailData)
            } else {
                completion(nil, nil)
            }
        }
    }
    
     //MARK: - Object CRUD
    
    func getPublicObjectsFromWbeb(tableView: UITableView?, collectionView: UICollectionView?) {
        let urlComponent = gs.getUrlComponents(path: "/objects/public")
        guard let url = urlComponent.url else { return }
        dataProvider.downloadPublicData(url: url) { data in
            guard let data = data else { return }
            //UserDefaults.standard.set(data, forKey: url.absoluteString)
            let objectsJSON: [Object]? = self.getJSONArray(from: data)
            guard let objects = objectsJSON else { return }
            self.objects = objects
            if tableView != nil {
                 DispatchQueue.main.async {
                    tableView?.reloadData()
                 }
            }
            if collectionView != nil {
                DispatchQueue.main.async {
                    collectionView?.reloadData()
                }
            }
        }
    }
    
    
    
    func getObjectsFromWbeb(tableView: UITableView?, collectionView: UICollectionView?) {
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
                 DispatchQueue.main.async {
                    tableView?.reloadData()
                 }
            }
            if collectionView != nil {
                DispatchQueue.main.async {
                    collectionView?.reloadData()
                }
            }
        }
    }
    
    func postObjectToWeb(object: Object, loadObject: LoadObject) {
        let urlComponent = gs.getUrlComponents(path: "/object")
        guard let url = urlComponent.url else { return }
        dataProvider.login = currentUser.username
        dataProvider.password = currentUser.password
        guard let body = putJSONData(from: object) else { return }
        dataProvider.runRequest(method: .post, url: url, body: body) { data in
            guard let data = data else { return }
            let objectJSON: Object? = self.getJSONObject(from: data)
            guard let object = objectJSON else { return }
            guard let name = object.internalFilename, let dataFile = loadObject.data, let dataThumbnail = loadObject.thumbnail else { return }
            if self.dataProvider.saveDataToFile(fileName: name, fileExt: "usdz", data: dataFile),
                self.dataProvider.saveDataToFile(fileName: name, fileExt: "png", data: dataThumbnail)  {
                self.saveFileServer(object: object, loadObject: loadObject)
            }
        }
    }
    
    func putObjectToWeb(object: Object, collectionView: UICollectionView?) {
        guard let id = object.id else { return }
        let urlComponent = gs.getUrlComponents(path: "/object/\(id)")
        guard let url = urlComponent.url else { return }
        dataProvider.login = currentUser.username
        dataProvider.password = currentUser.password
        guard let body = putJSONData(from: object) else { return }
        dataProvider.runRequest(method: .put, url: url, body: body) { data in
            guard let data = data else { return }
            if collectionView != nil {
                DispatchQueue.main.async {
                    collectionView?.reloadData()
                }
            }
            print("Response: \(String(data: data, encoding: .utf8) ?? "")")
        }
    }
    
    func deleteObjectToWeb(object: Object, collectionView: UICollectionView?) {
        guard let id = object.id else { return }
        let urlComponent = gs.getUrlComponents(path: "/object/\(id)")
        guard let url = urlComponent.url else { return }
        dataProvider.login = currentUser.username
        dataProvider.password = currentUser.password
        dataProvider.runRequest(method: .delete, url: url, body: nil) { data in
            guard let data = data else { return }
            print("Response: \(String(data: data, encoding: .utf8) ?? "")")
            if collectionView != nil {
                 DispatchQueue.main.async {
                    collectionView?.reloadData()
                }
            }
        }
    }
    
    func saveObject(from loadObject: LoadObject) {
        guard let userId = currentUser.id, let urlSource = loadObject.urlSource else { return }
        var maxId = 0
        for object in self.objects {
            if let id = object.id,
                id > maxId {
                maxId = object.id!
            }
        }
        let id = maxId + 1
        let object = Object(id: id, userId: userId, name: loadObject.name, desc: loadObject.comment, urlSource: urlSource, urlServer: nil, urlThumbnail: nil, date: Date(), ispublic: 0)
        
        postObjectToWeb(object: object, loadObject: loadObject)
    }

    
    func saveFileServer(object: Object, loadObject: LoadObject) {
        guard let filename = object.internalFilename, let fileData = loadObject.data, let thumbnailData = loadObject.thumbnail else { return }
        let objectFile = ObjectFile(filename: filename, fileData: fileData, thumbnailData: thumbnailData)
        guard let body = putJSONData(from: objectFile) else { return }
        let urlComponent = gs.getUrlComponents(path: "/file")
        guard let url = urlComponent.url else { return }
        dataProvider.login = currentUser.username
        dataProvider.password = currentUser.password
        dataProvider.runRequest(method: .post, url: url, body: body) { data in
            guard let _ = data else { return }
            self.store.delete(loadObject: loadObject)
            self.getObjectsFromWbeb(tableView: nil, collectionView: nil)
        }
        
    }
        
    
    //MARK: - User CRUD
    
    func getUsersFromWeb(tableView: UITableView?, collectionView: UICollectionView?) {
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
                DispatchQueue.main.async {
                    tableView?.reloadData()
                }
            } else {
                self.currentUser = users.filter({$0.username == self.checkSavedUser().username}).first
            }
            if collectionView != nil {
                DispatchQueue.main.async {
                    collectionView?.reloadData()
                }
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
            let usersJSON: [User]? = self.getJSONArray(from: data)
            
            guard let _ = usersJSON else {
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
            self.getUsersFromWeb(tableView: nil, collectionView: nil)
            self.currentUser = self.users.filter({$0.username == user.username!}).first
            self.performSegue(withIdentifier: "mainSegue", sender: nil)
        }
    }
    
    func tabbarSetup(user: User?, tbc: UITabBarController?) {
        tbc?.viewControllers = self.initialTBCViewControllers
        if user == nil {
            tbc?.viewControllers?.remove(at: 1)
            tbc?.viewControllers?.remove(at: 1)
        } else {
            self.store.fetchLoadObjects()
            self.loadObjects = self.store.fetchedLoadObjects
            tbc?.tabBar.items?[1].badgeValue = gs.getStringForBadgeFrom(int: loadObjects.count)
            if let user = user, user.isadmin ?? 0 != 1  {
                tbc?.viewControllers?.remove(at: 2)
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
        currentUser = nil
        self.performSegue(withIdentifier: "mainSegue", sender: nil)
    }
    
    @IBAction func returnFromSettings(unwindSegue: UIStoryboardSegue) {
    }
}
