# SqliteSample  
Swift sqilte manager and sample code
#### 將原生生物辨識 api 包裝為工具使用
- SqliteManager
- SqliteSampleCode
***
## How to use
>- 需先在 project 中加入 __`libsqlite3.tbd`__
>- 將 __`SqliteManager.swift`__ 檔案引進 project 中  
##  
### function 使用  
```swift
func checkSqliteDB(dbName: String) -> Bool
```  
Check if database is exist, return __`true`__ if exist otherwise __`false`__  
  
```swift
func closeDatabase()
```  
Close database  
  
```swift
func createDataTable(tableName: String, fieldsAndType: Dictionary<String, String>, foreignKeyStatments: Array<String>?)
```  
To create database if table not exist, else do nothing  
  
```swift
func queryAllDataTable(tableName: String) -> Array<Dictionary<String, String>>
```  
Query all datas from table  
  
```swift
func queryAllDataTable(tableName: String, fields: String?, condition: String?, order: String?) -> Array<Dictionary<String, String>>
```  
Query datas from table with condition  
  
```swift
func queryByInnerJoinWithTables(tablesName: Array<String>, fields: String?, conditions: Array<String>) -> Array<Dictionary<String, String>>
```  
select * from record join stockRoom join items join categorys on record.stockroomId == stockRoom.id and record.ItemId == items.id and items.CategoryId == categorys.id  
  
```swift
func insertData(dataDic: Dictionary<String, String>, toTable: String) -> Bool
```  
Insert datas to table  
  
```swift
func updateData(dataDic: Dictionary<String, String>, condition: String, toTable: String) -> Bool
```  
Update datas to table  
  
```swift
func deleteDataFrom(tableName: String, condition: String) -> Bool
```  
Delete data from table  
  
```swift
func queryLastDataFrom(tableName: String) -> Array<Dictionary<String, String>>
```  
Query last data from table  
  
```swift
func execute(sql: String) -> Bool
```  
Execute command  
  
