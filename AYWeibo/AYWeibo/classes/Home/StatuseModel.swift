//
//  StatusesModel.swift
//  AYWeibo
//
//  Created by Ayong on 16/6/23.
//  Copyright © 2016年 Ayong. All rights reserved.
//

import UIKit

class StatuseModel: NSObject {
    /// 微博创建时间
    var created_at: String?
    
    /// 字符串型的微博ID
    var idstr: String?
    
    /// 微博信息内容
    var text: String?
    
    /// 微博来源
    var source: String?
    
    /// 微博作者的用户信息
    var user: UserModel?
    


    init(dict: [String: AnyObject]) {
        super.init()
        self.setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    override func setValue(value: AnyObject?, forKey key: String) {
        if key == "user" {
            user = UserModel(dict: value as! [String: AnyObject])
            return
        }
        
        super.setValue(value, forKey: key)
    }
    
    override var description: String {
        let keys = ["created_at", "idstr", "text", "source", "user"]
        let dict = dictionaryWithValuesForKeys(keys)
        
        return "\(dict)"
    }
}
