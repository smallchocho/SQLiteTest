//
//  SQLiteManager.swift
//  SQLiteTest
//
//  Created by 黃聖傑 on 2018/5/28.
//  Copyright © 2018年 seaFoodBon. All rights reserved.
//

import Foundation
class SQLiteManager{
    static let shared = SQLiteManager()
    private init(){}
    var db:OpaquePointer?
    var statement:OpaquePointer?
    func openSQLiteOnLine()->Bool{
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let path = urls.first?.absoluteString else{ return false }
        let sqlitePath = path + "sqlite3.db"
        if sqlite3_open(sqlitePath,&db) == SQLITE_OK{
            return true
        }
        return false
    }
    func creatSQLiteTable()->Bool{
        let sql = "create table if not exists students "
            + "( id integer primary key autoincrement, "
            + "name text, height double)" as NSString
        
        if sqlite3_exec(db, sql.utf8String, nil, nil, nil)
            == SQLITE_OK{
            return true
        }
        return false
    }
    func addData(){
        let sql = "insert into students "
            + "(name, height) "
            + "values ('小強', 178.2)" as NSString
        if sqlite3_prepare_v2(db, sql.utf8String, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE {
                print("新增資料成功")
            }
            sqlite3_finalize(statement)
        }
    }
    func loadData(){
        
    }
}
