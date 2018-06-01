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
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        registerForKeyboardNotifications()
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
        var info = notification.userInfo!
//        let keyboardy = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.origin.y
        guard let activeField = self.activeField else{ return }
        guard let keyboardHeight:CGFloat = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size.height else{ return }
        let keyboardYPosition:CGFloat = self.view.frame.height - keyboardHeight
        let textFieldYPosition:CGFloat = activeField.frame.origin.y
        let textFieldHeight:CGFloat = activeField.frame.height
        
        if keyboardYPosition < (textFieldYPosition + textFieldHeight){
            let yOffset = (textFieldYPosition - textFieldHeight)
            self.view.frame.origin.y -= yOffset
        }
        self.tempFrame = self.view.frame
//        self.scrollView.contentInset = contentInsets
//        self.scrollView.scrollIndicatorInsets = contentInsets
        
//        var aRect : CGRect = self.view.frame
//        aRect.size.height -= keyboardSize!.height
//        if let activeField = self.activeField {
//            if (!aRect.contains(activeField.frame.origin)){
////                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
//            }
//        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
//        var info = notification.userInfo!
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
//        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
//        self.scrollView.contentInset = contentInsets
//        self.scrollView.scrollIndicatorInsets = contentInsets
//        self.view.endEditing(true)
//        self.scrollView.isScrollEnabled = false
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
