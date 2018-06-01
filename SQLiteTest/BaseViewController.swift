//
//  BaseViewController.swift
//  SQLiteTest
//
//  Created by 黃聖傑 on 2018/6/1.
//  Copyright © 2018年 seaFoodBon. All rights reserved.
//

import UIKit
class BaseViewController:UIViewController{
    var tempFrame:CGRect!
    var activeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
    }
    
    fileprivate func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    fileprivate func deregisterFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @objc func keyboardWasShown(notification: NSNotification){
        self.tempFrame = self.view.frame
        var info = notification.userInfo!
//et keyboardy = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.origin.y
        guard let keyboardHeight:CGFloat = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else{ return }
        let keyboardYPosition:CGFloat = self.view.frame.height - keyboardHeight
        let activeFieldFrame = self.activeField.convert(self.activeField.bounds, to: self.view)
        let textFieldYPosition:CGFloat = activeFieldFrame.origin.y
        let textFieldHeight:CGFloat = activeFieldFrame.height
        let textFieldBottomYPosition = textFieldYPosition + textFieldHeight
        if keyboardYPosition < textFieldBottomYPosition{
            let yOffset = (textFieldBottomYPosition - keyboardYPosition)
            self.view.frame.origin.y -= yOffset
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        self.view.frame = self.tempFrame
    }
 
}

extension BaseViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
}
