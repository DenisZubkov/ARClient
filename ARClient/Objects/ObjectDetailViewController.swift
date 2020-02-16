//
//  ObjectDetailViewController.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 16.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit

class ObjectDetailViewController: UIViewController, UITextFieldDelegate {

    
    let gs = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    let dataProvider = DataProvider()
    var object: Object?
    var mainCollectionView: UICollectionView?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var isPublicSwitch: UISwitch!
    @IBOutlet weak var isPublicLabel: UILabel!
    
    
    @IBAction func isPublicSwiched(_ sender: UISwitch) {
        object?.ispublic = isPublicSwitch.isOn ? 1 : 0
        isPublicLabel.text = object?.ispublic == 1 ? "Публичный доступ" : "Приватный доступ"
    }
    

    @IBAction func okButtonPressed(_ sender: UIBarButtonItem) {
        object?.name = nameTextField.text
        object?.desc = descTextField.text
        object?.ispublic = isPublicSwitch.isOn ? 1 : 0
        self.rootViewController.putObjectToWeb(object: object!, collectionView: mainCollectionView)
        self.performSegue(withIdentifier: "ReturnFromEditModelUnwind", sender: self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
       
        self.performSegue(withIdentifier: "ReturnFromEditModelUnwind", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        descTextField.delegate = self
        addTapGestureToHideKeyboard()
        nameTextField.text = object?.name
        descTextField.text = object?.desc
        isPublicSwitch.isOn = object?.ispublic == 1 ? true : false
        isPublicLabel.text = object?.ispublic == 1 ? "Публичный доступ" : "Приватный доступ"

        // Do any additional setup after loading the view.
    }
    
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapGesture() {
        if nameTextField.isEditing {
           nameTextField.resignFirstResponder()
        }
        if descTextField.isEditing {
            descTextField.resignFirstResponder()
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
                descTextField.becomeFirstResponder()
            } else if textField.tag == 1 {
                nameTextField.becomeFirstResponder()
            }
        }
        return false
    }


}
