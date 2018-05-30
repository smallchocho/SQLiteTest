//
//  ViewController.swift
//  SQLiteTest
//
//  Created by 黃聖傑 on 2018/5/28.
//  Copyright © 2018年 seaFoodBon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var dataBaseManager:SQLiteManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        dataBaseManager = self.initSQLiteData()
        self.readSQLiteData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSQLiteData()->SQLiteManager?{
        guard let manager = SQLiteManager(path: SQLiteManager.sqlitePath) else{ return nil }
        guard manager.creatStudentsDefaultData() else{ return nil }
        return manager
    }
    
    func readSQLiteData(){
        dataBaseManager?.readData(name: SQLiteManager.students, cond: "1 == 1", order: nil){
            (success:Bool,statement:OpaquePointer?) in
            guard success else{ return }
            let id = sqlite3_column_int(statement, 0)
            let name = String(cString: sqlite3_column_text(statement, 1))
            let height = sqlite3_column_double(statement, 2)
            print("id = \(id),name = \(name),height = \(height)")
        }
    }

}

