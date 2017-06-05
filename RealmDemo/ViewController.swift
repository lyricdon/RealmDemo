//
//  ViewController.swift
//  RealmDemo
//
//  Created by lyricdon on 2017/5/26.
//  Copyright © 2017年 modernmedia. All rights reserved.
//

import UIKit
import RealmSwift

// Realm都是延迟加载的，只有当属性被访问时，才能够读取相应的数据。不像通常数据库，查询后，查询结果是从数据库拷贝一份出来放在内存中的。而Realm的查询结果应该说是数据库数据的引用，就算你查出来，如果不用也不会占用什么内存

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var dFormatter = DateFormatter()
    
    // 结果保存
    var consumeItems: Results<ConsumeItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        newUserRealm(username: "testUser")
//        realmWrite()
        realmRead()
        
    }

    func realmRead() {
        
        dFormatter.dateFormat = "MM月dd日 HH:mm"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        let realm = try! Realm()
//        consumeItems = realm.objects(ConsumeItem.self)
        
        let predicate = NSPredicate(format: "type.name = 'shopping' AND cost > 1 ")
        consumeItems = realm.objects(ConsumeItem.self).filter(predicate)
//        consumeItems = realm.objects(ConsumeItem.self).filter("cost > 1").sorted(byKeyPath: "cost")
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return consumeItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let item = consumeItems![indexPath.row]
        cell.textLabel?.text = item.name + "¥" + String(format: "%.1f", item.cost)
        cell.detailTextLabel?.text = dFormatter.string(from: item.date)
        return cell
    }
    
    
    func realmWrite() {
        // 使用默认数据库
        let realm = try! Realm()
        // 查询所有消费记录
        let items = realm.objects(ConsumeType.self)
        // 已有不插入
        if items.count > 0 {
            return
        }
        
        // 创建类型
        let typeOne = ConsumeType()
        typeOne.name = "shopping"
        let typeTwo = ConsumeType()
        typeTwo.name = "entertainment"
        
        // 创建记录
        let itemOne = ConsumeItem(value: ["buy a computer",15999.00,Date(),typeOne]) //可使用数组创建
        
        let itemTwo = ConsumeItem()
        itemTwo.name = "look a film"
        itemTwo.cost = 230.00
        itemTwo.date = Date(timeIntervalSinceNow: -36000)
        itemTwo.type = typeTwo
        
        let itemThree = ConsumeItem()
        itemThree.name = "buy some cakes"
        itemThree.cost = 122.50
        itemThree.date = Date(timeIntervalSinceNow: -72000)
        itemThree.type = typeOne
        
        try! realm.write {
            realm.add(itemOne)
            realm.add(itemTwo)
            realm.add(itemThree)
        }
        
        print(realm.configuration.fileURL ?? "null")
    }
 
    // 自定义
    func newUserRealm(username: String) {
        var config = Realm.Configuration()
        
        // 默认目录, 新文件名
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
        Realm.Configuration.defaultConfiguration = config
    }
    
    // 数据迁移
    // 在(application:didFinishLaunchingWithOptions:)中进行配置
    func dateMigrate() {
        let config = Realm.Configuration(
            // 设置新的架构版本。这个版本号必须高于之前所用的版本号
            // （如果您之前从未设置过架构版本，那么这个版本号设置为 0）
            schemaVersion: 1,
            
            // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
            migrationBlock: { migration, oldSchemaVersion in
                // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
                }
        })
        
        // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
        Realm.Configuration.defaultConfiguration = config
        
        // 现在我们已经告诉了 Realm 如何处理架构的变化，打开文件之后将会自动执行迁移
        let realm = try! Realm()
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    // enumerateObjects(ofType:_:) 方法遍历了存储在 Realm 文件中的每一个“Person”对象
                    migration.enumerateObjects(ofType: ConsumeItem.className()) { oldObject, newObject in
                        // 将名字进行合并，存放在 fullName 域中
                        let firstName = oldObject!["firstName"] as! String
                        let lastName = oldObject!["lastName"] as! String
                        newObject!["fullName"] = "\(firstName) \(lastName)"
                    }
                }
        })
    }
}

