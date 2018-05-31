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
    static let students = "students"
    static let studentsColumsInfo = ["id integer primary key autoincrement","name text not null","height double not null"]
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
            print("建立\(name) Table成功")
            return true
        }
        print("建立\(name) Table失敗")
        return false
    }
    
    func creatStudentsDefaultData()->Bool{
        var isHasDefaultData = false
        readData(name: SQLiteManager.students, cond: "1 == 1", order: nil) { (success, statement) in
            if success {
                isHasDefaultData = true
            }
        }
        guard !isHasDefaultData else{
            print("\(SQLiteManager.students) 資料已存在")
            return true
        }
        guard creatSQLiteTable(name: SQLiteManager.students, columsInfo: SQLiteManager.studentsColumsInfo) else{
            return false
        }
        guard self.creatData(name: SQLiteManager.students, rowInfo: ["name":"Justin","height":189.9]) else{
            return false
        }
        return true
    }
    
    
    func creatData(name:String,rowInfo:[String:Any])->Bool{
        var statement:OpaquePointer?
        var infoValues:[String] = []
        for value in rowInfo.values{
            switch value {
            case let v as String:
                let str = "'\(v)'"
                infoValues.append(str)
            case let v as Double:
                let str = String(v)
                infoValues.append(str)
            case let v as Int:
                let str = String(v)
                infoValues.append(str)
            case let v as Float:
                let str = String(v)
                infoValues.append(str)
            default :
                assert(false, "此格式尚未支援")
            }
        }
        let sql = "insert into \(name) "
            + "(\(rowInfo.keys.joined(separator: ","))) "
            + "values "
            + "(\(infoValues.joined(separator: ",")))"
        guard sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil) == SQLITE_OK else{
            print("準備建立\(SQLiteManager.students) data失敗")
            return false
        }
        guard sqlite3_step(statement) == SQLITE_DONE else{
            sqlite3_finalize(statement)
            print("建立\(SQLiteManager.students) data失敗")
            return false
        }
        print("建立\(SQLiteManager.students) data成功")
        return true
        
    }
    func readData(name:String,cond:String?,order:String?,completion:(Bool,OpaquePointer?)->()){
        var statement:OpaquePointer?
        var sql = "select * from \(name)"
        if let condition = cond {
            sql += " where \(condition)"
        }
        if let orderBy = order{
            sql += " order by \(orderBy)"
        }
        let sqlitePrepare = sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil)
        guard sqlitePrepare == SQLITE_OK else{
            print("準備讀取\(name) 資料失敗")
            completion(false,nil)
            return
        }
        print("準備讀取\(name) 資料成功")
        while sqlite3_step(statement) == SQLITE_ROW {
            completion(true,statement)
        }
        sqlite3_finalize(statement)
    }
    
    func updateDate(name:String,cond :String?, rowInfo :[String:Any])->Bool{
        var statement:OpaquePointer?
        var sql = "update \(name) set"
        var rowInfoValue:[String:String] = [:]
        for info in rowInfo{
            if let v = info.value as? String{
                let str = "'\(v)'"
                rowInfoValue[info.key] = str
            }
            if let v = info.value as? Double{
                let str = String(v)
                rowInfoValue[info.key] = str
            }
            if let v = info.value as? Int{
                let str = String(v)
                rowInfoValue[info.key] = str
            }
            if let v = info.value as? Float{
                let str = String(v)
                rowInfoValue[info.key] = str
            }
        }
        var info:[String] = []
        for (k,v) in rowInfoValue{
            info.append(" \(k) = \(v)")
        }
        sql += info.joined(separator: ",")
        if let condition = cond {
            sql += " where \(condition)"
        }
        let sqlite3Prepare = sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil)
        guard sqlite3Prepare == SQLITE_OK else{
            print("準備更新\(name) 資料失敗")
            return false
        }
        guard sqlite3_step(statement) == SQLITE_DONE else{
            sqlite3_finalize(statement)
            print("更新\(name) 資料失敗")
            return false
        }
        sqlite3_finalize(statement)
        print("更新\(name) 資料成功")
        return true
    }
    func deleteData(name:String,cond:String?)->Bool{
        var statement:OpaquePointer?
        var sql = "delete from \(name)"
        if let condition = cond {
            sql += " where \(condition)"
        }
        let sqlite3Prepare = sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil)
        guard sqlite3Prepare == SQLITE_OK else{
            print("準備刪除\(name) 資料失敗")
            return false
        }
        if sqlite3_step(statement) == SQLITE_DONE {
            print("刪除\(name) 資料成功")
            return true
        }
        sqlite3_finalize(statement)
        print("刪除\(name) 資料失敗")
        return false
    }
}
