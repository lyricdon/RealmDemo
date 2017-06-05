//
//  ConsumeType.swift
//  RealmDemo
//
//  Created by lyricdon on 2017/5/27.
//  Copyright © 2017年 modernmedia. All rights reserved.
//

import UIKit
import RealmSwift

class ConsumeType: Object {
    dynamic var name = ""
}


class ConsumeItem: Object {
    

//    // 主键
//    dynamic var id = 0
//    override static func primaryKey() -> String? {
//        return "id"
//    }
//    
//    // 索引
//    dynamic var title = ""
//    override static func indexedProperties() -> [String] {
//        return ["title"]
//    }
//    
//    // 忽略
//    dynamic var tmpID = 0
//    override static func ignoredProperties() -> [String] {
//        return ["tmpID"]
//    }
    
    dynamic var name = ""
    dynamic var cost = 0.00
    dynamic var date = Date()
    dynamic var type: ConsumeType?
}
