//
//  SqliteManager.swift
//  FoodStorage
//
//  Created by Stanley on 2018/3/12.
//  Copyright © 2018年 Stanley. All rights reserved.
//

import Foundation
import SQLite3

class SqliteManager {
    
    static let shared: SqliteManager = {
        return SqliteManager()
    }()
    
    private var db: OpaquePointer? = nil
    
    /// Check if database is exist, return true if exist otherwise false
    func checkSqliteDB(dbName: String) -> Bool {
        do {
            let urls = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let sqlitePath = String(format: "%@%@.sqlite", urls.absoluteString, dbName)
            
            if sqlite3_open(sqlitePath, &db) == SQLITE_OK {
                print("資料庫連線成功")
                return true
            } else {
                print("資料庫連線失敗")
                return false
            }
        }
        catch {
            return false
        }
    }
    
    /// Close database
    func closeDatabase() {
        if db != nil {
            sqlite3_close(db)
        }
    }
    
    /// To create database if table not exist, else do nothing
    func createDataTable(tableName: String, fieldsAndType: Dictionary<String, String>, foreignKeyStatments: Array<String>?) {
        var sql = "CREATE TABLE IF NOT EXISTS \(tableName) " + "( id integer primary key autoincrement "
        
        for field in fieldsAndType.keys {
            sql += String(format: ", '%@' %@ DEFAULT ''", field, fieldsAndType[field]!)
        }
        
        if foreignKeyStatments != nil {
            for foreignKeyStatment in foreignKeyStatments! {
                sql += String(format: ", %@", foreignKeyStatment)
            }
        }
        
        sql += ")"
        
        if sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK {
            print("建立資料表成功")
        }
        else {
            
        }
    }
    
    /// Query all datas from table
    func queryAllDataTable(tableName: String) -> Array<Dictionary<String, String>> {
        var resultAry = Array<Dictionary<String, String>>()
        
        let sqlString = "SELECT * FROM \(tableName)"
        resultAry = self.find(sqlString: sqlString)
        
        return resultAry
    }
    
    /// Query datas from table with condition
    func queryAllDataTable(tableName: String, fields: String?, condition: String?, order: String?) -> Array<Dictionary<String, String>> {
        var resultAry = Array<Dictionary<String, String>>()
        
        let sqlString = String(format: "SELECT %@ FROM %@ WHERE %@ %@", fields == nil ? "*" : fields!, tableName, condition == nil ? "1==1" : condition!, order == nil ? "" : order!)
        resultAry = self.find(sqlString: sqlString)
        
        return resultAry
    }
    
    /// select * from record join stockRoom join items join categorys on record.stockroomId == stockRoom.id and record.ItemId == items.id and items.CategoryId == categorys.id
    func queryByInnerJoinWithTables(tablesName: Array<String>, fields: String?, conditions: Array<String>) -> Array<Dictionary<String, String>> {
        var sqlString = String(format: "SELECT %@ FROM", fields == nil ? "*" : fields!)
        
        for tableName in tablesName {
            sqlString += String(format: " %@ JOIN", tableName)
        }
        sqlString = String(sqlString.dropLast(4))
        sqlString += "ON"
        
        for condition in conditions {
            sqlString += String(format: " %@ AND", condition)
        }
        sqlString = String(sqlString.dropLast(4))
        
        var resultAry = Array<Dictionary<String, String>>()
        resultAry = self.find(sqlString: sqlString)
        return resultAry
    }
    
    /// Insert datas to table
    func insertData(dataDic: Dictionary<String, String>, toTable: String) -> Bool {
        var sqlString = "INSERT INTO \(toTable) "
        var fields = "("
        var values = "("
        
        for field in dataDic.keys {
            fields += String(format: "%@,", field)
            values += String(format: "'%@',", dataDic[field]!)
        }
        
        fields.removeLast()
        values.removeLast()
        fields += ")"
        values += ")"
        
        sqlString += String(format: "%@ values %@", fields, values)
        
        return self.update(sqlString: sqlString)
    }
    
    /// Update datas to table
    func updateData(dataDic: Dictionary<String, String>, condition: String, toTable: String) -> Bool {
        var sqlString = "UPDATE \(toTable) SET "
        var values = ""
        
        for field in dataDic.keys {
            values += String(format: "%@='%@',", field, dataDic[field]!)
        }
        values.removeLast()
        sqlString += String(format: "%@ WHERE %@", values, condition)
        
        return self.update(sqlString: sqlString)
    }
    
    /// Delete data from table
    func deleteDataFrom(tableName: String, condition: String) -> Bool {
        let sqlString = "DELETE FROM \(tableName) WHERE \(condition)"
        return self.update(sqlString: sqlString)
    }
    
    /// Query last data from table
    func queryLastDataFrom(tableName: String) -> Array<Dictionary<String, String>> {
        let sqlString = "SELECT * FROM \(tableName) WHERE ROWID == \(sqlite3_last_insert_rowid(db))"
        return self.find(sqlString: sqlString)
    }
    
    /// Execute command
    func execute(sql: String) -> Bool {
        if sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK {
            return true
        }
        return false
    }
    
    //MARK: - private function
    private func find(sqlString: String) -> Array<Dictionary<String, String>> {
        var resultAry = Array<Dictionary<String, String>>()
        
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, sqlString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                var resultDic = Dictionary<String, String>()
                
                for index in 0..<sqlite3_column_count(queryStatement) {
                    if let field_name = String.init(utf8String: sqlite3_column_name(queryStatement, index)) {
                        resultDic[field_name] = String(cString: sqlite3_column_text(queryStatement, index)!)
                    }
                }
                resultAry.append(resultDic)
            }
        }
        else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        return resultAry
    }
    
    private func update(sqlString: String) -> Bool {
        var success = false
        
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, sqlString, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_DONE {
                print("Successfully updated row.")
                success = true
            }
            else {
                print("Could not update row.")
                success = false
            }
        }
        else {
            print("INSERT statement could not be prepared.")
            success = false
        }
        sqlite3_finalize(queryStatement)
        
        return success
    }
}
