//
//  ViewController.swift
//  SQLiteTest
//
//  Created by 黃聖傑 on 2018/5/28.
//  Copyright © 2018年 seaFoodBon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func creatSQLiteData(){
        guard let db = SQLiteManager(path: SQLiteManager.sqlitePath) else{ return }
        let tableName = "students"
        _ = db.creatSQLiteTable(name: tableName, columsInfo: ["id integer primary key autoincrement","name text","height double"])
        guard db.creatData(name: tableName, rowInfo: ["name":"\'Justin\'","height":"189.9"]) else{ return }
        guard let statement = db.readData(name: tableName, cond: "1 == 1", order: nil) else{ return }
        while sqlite3_step(statement) == SQLITE_ROW{
            let id = sqlite3_column_int(statement, 0)
            let name = String(cString: sqlite3_column_text(statement, 1))
            let height = sqlite3_column_double(statement, 2)
            print("id = \(id),name = \(name),height = \(height)")
        }
    }

}

