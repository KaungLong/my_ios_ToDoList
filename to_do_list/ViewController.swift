//
//  ViewController.swift
//  to_do_list
//
//  Created by 危末狂龍 on 2022/10/11.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource {
    
    //陣列儲存文字訊息（待辦事項）
    var items = [String]()
    //建立表格以cell來儲存每項記事
    private let table: UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self,forCellReuseIdentifier: "cell")
        return table
    }()
    
    //主視窗顯示
    override func viewDidLoad() {
        super.viewDidLoad()
        //在NavigationController上的標題
        title =  "待辦事項"
        //如果在UserDefaults中存在先前以forKey: "items"儲存的文字列表則讓他等於現在的items，沒有則為[]
        self.items = UserDefaults.standard.stringArray(forKey: "items") ?? []
        view.addSubview(table)
        //表格資料來源由ViewController本身提供
        table.dataSource = self
        //新增導覽視窗列右鍵，種類為新增,目標對象ViewController自身,點擊觸發didTapAdd
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        //新增導覽視窗列左鍵，直接讓他成為預設的編輯按鈕
        navigationItem.leftBarButtonItem = editButtonItem
    }
    //點擊觸發提醒視窗
    @objc private func didTapAdd(){
        //建立一個提醒視窗
        let alert = UIAlertController(title: "新事項", message: "點擊來開始填寫～", preferredStyle: .alert)
        //UIAlertController中加入輸入框
        alert.addTextField{
            //提示文字
            field in field.placeholder = "輸入文字..."
        }
        //UIAlertController中加入選項按鍵UIAlertAction，預設style.cancel會直接關閉提醒窗不改變參數
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "完成", style: .default, handler: {
            //針對textFields內的第一個元素
            (_) in if let field = alert.textFields?.first{
                if let text = field.text, !text.isEmpty{
                    //如果text不為空，令currentItem等於UserDefaults中名為"items"的字串列表並把text存入
                    var currentItem =  UserDefaults.standard.stringArray(forKey: "items") ?? []
                    currentItem.append(text)
                    UserDefaults.standard.setValue(currentItem, forKey: "items")
                //新增事項到to do list （呈現畫面上）
                DispatchQueue.main.async {
                        self.items.append(text)
                        self.table.reloadData()
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
    //子頁面的佈局屬性（表格），給予table框架同view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
        table.backgroundColor = .systemGray 
        
    }
    //
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        table.setEditing(editing, animated: true)
    }
    
    //根據UITableViewDataSource協議須提供表格資料
    //返還所需要變動的section位置
    // Return the number of rows for the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    //創建單元格UITableViewCell物件在表格中，以"cell"識別並擁有獨立indexPath屬性
    // Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type. 設置cell類型
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        
        // Configure the cell’s contents. 分配內容
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    //要求數據源提交指定行的插入或刪除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         
         switch editingStyle {
             //若收到編輯模式為刪除
         case UITableViewCell.EditingStyle.delete:
             //讀取UserDefaults為currentItem
             var currentItem =  UserDefaults.standard.stringArray(forKey: "items") ?? []
             //從UserDefaults中移除存儲的items
             currentItem.remove(at: indexPath.row)
             //重新儲存
             UserDefaults.standard.setValue(currentItem, forKey: "items")
             //於table畫面上修改
             items.remove(at: indexPath.row)
             table.reloadData()
         default:
             break
         }
    }
}
