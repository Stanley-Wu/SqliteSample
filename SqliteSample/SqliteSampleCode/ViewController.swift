//
//  ViewController.swift
//  SqliteSample
//
//  Created by Stanley on 2020/11/27.
//  Copyright © 2020 Stanley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let databaseName: String = "SqliteSample"
    private let tableName: String = "ExampleTable"
    private var tableDatas: [[String: String]] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickAdd))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if SqliteManager.shared.checkSqliteDB(dbName: databaseName) {
            showAlertController(title: "資料庫連線成功", message: "")
            SqliteManager.shared.createDataTable(tableName: tableName, fieldsAndType: ["Name":"TEXT"], foreignKeyStatments: nil)
            
            tableDatas = SqliteManager.shared.queryAllDataTable(tableName: tableName)
        }
        else {
            showAlertController(title: "資料庫連線失敗", message: "")
        }
    }
    
    //MARK: - action
    @objc private func clickAdd() {
        showAddItemAlert()
    }
    
    //MARK: - private function
    private func showAlertController(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: handler)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func showAddItemAlert() {
        let alertController = UIAlertController(title: "Add", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = ""
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak self] alert -> Void in
            guard self != nil else {
                return
            }
            
            let textField = alertController.textFields![0] as UITextField
            if textField.text != nil && textField.text! != "" {
                if SqliteManager.shared.insertData(dataDic: ["Name": textField.text!], toTable: self!.tableName) {
                    self!.tableDatas = SqliteManager.shared.queryAllDataTable(tableName: self!.tableName)
                }
            }
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tableDatas[indexPath.row]["Name"]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let data = tableDatas[indexPath.row]["Name"] ?? ""
            if SqliteManager.shared.deleteDataFrom(tableName: tableName, condition: "Name=\(data)") {
                tableDatas = SqliteManager.shared.queryAllDataTable(tableName: tableName)
            }
        }
    }
}
