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
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var isAdminSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTextField.delegate = self
        passwordTextField.delegate = self
        // Do any additional setup after loading the view.
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
        return checkTextField(textField: textField)
    }

    @IBAction func isAdminSwitched(_ sender: UISwitch) {
        
    }
    
    @IBAction func userSaved(_ sender: UIButton) {
        var user = User()
        user.username = userTextField.text
        user.password = passwordTextField.text
        user.salt = ""
        user.isadmin = isAdminSwitch.isOn ? 1 : 0
        var maxId = 0
        for user in rootViewController.users {
            if let id = user.id,
                id > maxId {
                maxId = user.id!
            }
        }
        user.id = maxId + 1
        rootViewController.uploadUserToWbeb(user: user)
        
    }
    
    @IBAction func userDeleted(_ sender: UIButton) {
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
