//
//  UserDetailViewController.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 09.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController, UITextFieldDelegate {
    
    let gs = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    let dataProvider = DataProvider()
    var user: User?
    var editUser: User?
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var isAdminSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTextField.delegate = self
        passwordTextField.delegate = self
        editUser = user
        saveButton.isEnabled = checkUserChange()
        buttonSetup()
        if user == nil {
            deleteButton.isEnabled = false
        }
        userTextField.text = user?.username
        passwordTextField.text = user?.password
        isAdminSwitch.isOn = user?.isadmin ?? 0 == 1 ? true : false
        // Do any additional setup after loading the view.
    }
    
    func buttonSetup() {
        saveButton.tintColor = gs.buttonOkTextColor
        saveButton.backgroundColor = gs.buttonOkBgColor
        saveButton.layer.cornerRadius = CGFloat(gs.buttonCornerRadius)
        deleteButton.tintColor = gs.buttonCancelTextColor
        deleteButton.backgroundColor = gs.buttonCancelBgColor
        deleteButton.layer.cornerRadius = CGFloat(gs.buttonCornerRadius)
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
        if let text = textField.text {
            let haveUser = rootViewController.users.filter({$0.username == text && $0.id != user?.id ?? -9999})
            if haveUser.count > 0 {
                let alert = UIAlertController(title: "Пользователь с именем \(text) уже существует!",
                    message: "Введите другое имя пользователя",
                    preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    textField.text = nil
                }
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = checkUserChange()
    }
    
    func checkUserChange() -> Bool {
        if user?.username == userTextField.text && user?.password == passwordTextField.text && (user?.isadmin == 1 ? true : false) == isAdminSwitch.isOn {
            return false
        } else {
            return true
        }
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
                saveButton.becomeFirstResponder()
            }
        }
        return false
    }

    @IBAction func isAdminSwitched(_ sender: UISwitch) {
        
    }
    
    @IBAction func userSaved(_ sender: UIButton) {
        if self.checkUserChange() {
            var message = ""
            if user == nil {
                message = "Вы действительно хотите сохранить нового пользователя \(userTextField.text ?? "")"
            } else {
                message = "Вы действительно хотите сохранить изменения для пользователя \(user?.username ?? "")"
            }
            let alert = UIAlertController(title: "Сохранение",
                                          message:message,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                
                if self.user == nil {
                    self.user = User()
                    self.user?.username = self.userTextField.text
                    self.user?.password = self.passwordTextField.text
                    self.user?.salt = ""
                    self.user?.isadmin = self.isAdminSwitch.isOn ? 1 : 0
                    var maxId = 0
                    for user in self.rootViewController.users {
                        if let id = user.id,
                            id > maxId {
                            maxId = user.id!
                        }
                    }
                    self.user?.id = maxId + 1
                    self.rootViewController.postUserToWeb(user: self.user!)
                } else {
                    self.user?.username = self.userTextField.text
                    self.user?.password = self.passwordTextField.text
                    self.user?.salt = ""
                    self.user?.isadmin = self.isAdminSwitch.isOn ? 1 : 0
                    self.rootViewController.putUserToWeb(user: self.user!)
                }
                
                if self.user?.id == self.rootViewController.currentUser.id {
                    self.performSegue(withIdentifier: "ReturnFromEditToLoginUnwind", sender: self)
                } else {
                    self.performSegue(withIdentifier: "ReturnFromEditUnwind", sender: self)
                }
            }
            alert.addAction(okAction)
            let cancelAction = UIAlertAction(title: "Отменить", style: .default) { (action) in
            }
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Нет изменений",
                                          message: "Нет изменений для сохранения",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.performSegue(withIdentifier: "ReturnFromEditUnwind", sender: self)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func userDeleted(_ sender: UIButton) {
        if let user = user, let id = user.id {
            let haveObjects = rootViewController.objects.filter({$0.userId == id}).count
            
            guard user.id! != rootViewController.currentUser.id! else {
                let alert = UIAlertController(title: "Активный пользователь",
                                              message: "Нельзя удалить текущего пользователя",
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                }
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
            }
            
            guard id  != 0 else {
                let alert = UIAlertController(title: "Главный пользователь!",
                                              message: "Пользователя \(user.username!) НЕЛЬЗЯ удалять!!!",
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                }
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
            }
            
            
            guard haveObjects == 0 else {
                let alert = UIAlertController(title: "Есть модели!",
                                              message: "Для удаления пользователя \(user.username!), удалите все его модели.",
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                }
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return 
            }
            
            
            
            let alert = UIAlertController(title: "Удаление пользователя",
                                          message: "Вы действительно хотите удалить пользователя \(user.username!)?",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.rootViewController.deleteUserToWeb(user: user)
                self.performSegue(withIdentifier: "ReturnFromEditUnwind", sender: self)
            }
            alert.addAction(okAction)
            let cancelAction = UIAlertAction(title: "Прервать", style: .default) { (action) in
            }
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
           
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
