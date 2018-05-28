//
//  SQLiteManager.swift
//  SQLiteTest
//
//  Created by 黃聖傑 on 2018/5/28.
//  Copyright © 2018年 seaFoodBon. All rights reserved.
//

import Foundation
class SQLiteManager{
    let sqlitePath:String
    init?(path:String){
        sqlitePath = path
        db = self.openSQLiteDatabase(path: sqlitePath)
        if db == nil { return nil }
    }
    
    var db:OpaquePointer?
    func openSQLiteDatabase(path:String)->OpaquePointer?{
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let path = urls.first?.absoluteString else{ return nil }
        let sqlitePath = path + "sqlite3.db"
        if sqlite3_open(sqlitePath,&db) == SQLITE_OK{
            print("成功打開Database:\(sqlitePath)")
            return db
        }
        return nil
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
    func creatData(){
        var statement:OpaquePointer?
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
    func readData(){
        var statement:OpaquePointer?
        let sql = "select * from students" as NSString
        let sqlitePrepare = sqlite3_prepare_v2(db, sql.utf8String, -1, &statement, nil)
        while sqlitePrepare == SQLITE_ROW{
            let id = sqlite3_column_int(statement, 0)
            if let nameValue = sqlite3_column_text(statement, 1){
                let name = String(cString: nameValue)
            }
            let height = sqlite3_column_double(statement, 2)
        }
    }
    func updateDate()->Bool{
        var statement:OpaquePointer?
        let sql = "update students set name='小強' where id = 1" as NSString
        let sqlite3Prepare = sqlite3_prepare_v2(db, sql.utf8String, -1, &statement, nil)
        guard sqlite3Prepare == SQLITE_OK else{ return false }
        if sqlite3_step(statement) == SQLITE_DONE{
            sqlite3_finalize(statement)
            return true
        }
        sqlite3_finalize(statement)
        return false
        
        
    }
    func deleteData()->Bool{
        var statement:OpaquePointer?
        let sql = "delete from students where id = 3" as NSString
        let sqlite3Prepare = sqlite3_prepare_v2(db, sql.utf8String, -1, &statement, nil)
        guard sqlite3Prepare == SQLITE_OK else{ return false }
        if sqlite3_step(statement) == SQLITE_DONE {
            sqlite3_finalize(statement)
            return true
        }
        sqlite3_finalize(statement)
        return false
    }
}
