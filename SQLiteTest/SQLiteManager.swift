//
//  SQLiteManager.swift
//  SQLiteTest
//
//  Created by 黃聖傑 on 2018/5/28.
//  Copyright © 2018年 seaFoodBon. All rights reserved.
//

import Foundation
class SQLiteManager{
    static let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
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
        print("不存在Database:\(sqlitePath)")
        return nil
    }
    func creatSQLiteTable(name:String,columsInfo:[String])->Bool{
        let columsInfoAddSeparator = columsInfo.joined(separator: ",")
        let sql = "create table if not exists \(name) "
            + "( \(columsInfoAddSeparator) )" as NSString
        if sqlite3_exec(db, sql.utf8String, nil, nil, nil)
            == SQLITE_OK{
            print("建立表格成功")
            return true
        }
        print("建立表格失敗")
        return false
    }
    func creatData(name:String,rowInfo:[String:String])->Bool{
        var statement:OpaquePointer?
        let sql = "insert into \(name) "
            + "(\(rowInfo.keys.joined(separator: ","))) "
            + "values "
            + "(\(rowInfo.values.joined(separator: ",")))"
        guard sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil) == SQLITE_OK else{
            print("新增資料失敗")
            return false
        }
        guard sqlite3_step(statement) == SQLITE_DONE else{
            sqlite3_finalize(statement)
            print("新增資料失敗")
            return false
        }
        print("新增資料成功")
        return true
        
    }
    func readData(name:String,cond:String?,order:String?)->OpaquePointer?{
        var statement:OpaquePointer?
        var sql = "select * from \(name)"
        if let condition = cond {
            sql += " where \(condition)"
        }
        if let orderBy = order{
            sql += " order by \(orderBy)"
        }
        sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil)
        return statement

    }
    func updateDate(name:String,cond :String?, rowInfo :[String:String])->Bool{
        var statement:OpaquePointer?
        var sql = "update \(name) set"
        var info:[String] = []
        for (k,v) in rowInfo{
            info.append("\(k) = \(v)")
        }
        sql += info.joined(separator: ",")
        if let condition = cond {
            sql += "where \(condition)"
        }
        let sqlite3Prepare = sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil)
        guard sqlite3Prepare == SQLITE_OK else{
            print("準備更新資料失敗")
            return false
        }
        guard sqlite3_step(statement) == SQLITE_DONE else{
            sqlite3_finalize(statement)
            print("更新資料失敗")
            return false
        }
        print("更新資料成功")
        return true
    }
    func deleteData(name:String,cond:String?)->Bool{
        var statement:OpaquePointer?
        var sql = "delete from \(name)"
        if let condition = cond {
            sql += "where \(condition)"
        }
        let sqlite3Prepare = sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil)
        guard sqlite3Prepare == SQLITE_OK else{
            print("準備刪除資料失敗")
            return false
        }
        if sqlite3_step(statement) == SQLITE_DONE {
            print("刪除資料成功")
            return true
        }
        sqlite3_finalize(statement)
        print("刪除資料失敗")
        return false
    }
}
