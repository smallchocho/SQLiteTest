//
//  ViewController.swift
//  SQLiteTest
//
//  Created by 黃聖傑 on 2018/5/28.
//  Copyright © 2018年 seaFoodBon. All rights reserved.
//

import UIKit

class ViewController: BaseViewController {
    
    @IBOutlet weak var displayDataTextView: UITextView!

    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    

    
    @IBOutlet weak var editNameTextField: UITextField!
    @IBOutlet weak var editHeightTextField: UITextField!
    
    
    var readResult:String = ""{
        didSet{
            displayDataTextView.text = readResult
        }
    }
    
    lazy var dataBaseManager:SQLiteManager? = { return self.initSQLiteManager() }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.readSQLiteData()
        self.initTextField()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func initTextField(){
        self.nameTextField.delegate = self
        self.heightTextField.delegate = self
        self.editNameTextField.delegate = self
        self.editHeightTextField.delegate = self
    }
    
    func initSQLiteManager()->SQLiteManager?{
        guard let manager = SQLiteManager(path: SQLiteManager.sqlitePath) else{ return nil}
        guard manager.creatStudentsDefaultData() else{ return nil}
        return manager
    }
    
    func readSQLiteData(cond:String? = "1 == 1"){
        var result = ""
        dataBaseManager?.readData(name: SQLiteManager.students, cond: cond, order: nil){
            (success:Bool,statement:OpaquePointer?) in
            guard success else{ return }
            let id = sqlite3_column_int(statement, 0)
            let name = String(cString: sqlite3_column_text(statement, 1))
            let height = sqlite3_column_double(statement, 2)
            result += "id = \(id), name = \(name), height = \(height)\n"
            
        }
        self.readResult = result
        
    }
    func creatSQLiteData(){
        let name = nameTextField.text ?? ""
        guard !name.isEmpty else{ return }
        guard let heightValue = heightTextField.text else{ return }
        guard let height = Double(heightValue) else{ return }
        let _ = dataBaseManager?.creatData(name: SQLiteManager.students, rowInfo: ["name":name ,"height":height])
    }
    
    func deleteSQLiteData(){
        let condition = self.createConditon(name: nameTextField.text , height: heightTextField.text)
        print(condition)
        if condition.isEmpty { return }
        let _ = dataBaseManager?.deleteData(name: SQLiteManager.students, cond: condition)
    }
    
    func updateSQLiteData(){
        let condition = self.createConditon(name: nameTextField.text , height: heightTextField.text)
        print(condition)
        var rowInfo:[String:Any] = [:]
        if let name = editNameTextField.text {
            rowInfo["name"] = name
        }
        if let heightValue = editHeightTextField.text {
            if let height = Double(heightValue){
                rowInfo["height"] = height
            }
        }
        let _ = dataBaseManager?.updateDate(name: SQLiteManager.students, cond: condition, rowInfo: rowInfo)
    }
    
    func createConditon(name:String?,height:String?)->String{
        var condition:String = ""
        if let name = name {
            if !name.isEmpty {
                condition += "name = '\(name)'"
            }
        }
        if let heightText = height{
            if let height = Double(heightText){
                if condition != "" { condition += " and "}
                condition += "height = \(height)"
            }
        }
        return condition
    }
    
    @IBAction func readButtonClicked(_ sender: UIButton) {
        var condition = self.createConditon(name: self.nameTextField.text, height: self.heightTextField.text)
        if condition.isEmpty {
            self.readSQLiteData()
            return
        }
        self.readSQLiteData(cond: condition)
    }
    
    
    @IBAction func onCreatButtonClicked(_ sender: UIButton) {
        self.creatSQLiteData()
        self.readSQLiteData()
    }
    
    @IBAction func onDeleteButtonClicked(_ sender: UIButton) {
        self.deleteSQLiteData()
        self.readSQLiteData()
    }
    
    @IBAction func onUpdateButtonClicked(_ sender: UIButton) {
        self.updateSQLiteData()
        self.readSQLiteData()
    }
    
}

