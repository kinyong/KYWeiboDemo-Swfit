//
//  NetWorkTools.swift
//  AYWeibo
//
//  Created by Ayong on 16/6/21.
//  Copyright © 2016年 Ayong. All rights reserved.
//

import UIKit
import Alamofire

class NetWorkTools: NSObject {
    /// 共享网络工具
    static let shareIntance = NetWorkTools()
    
    /// 获取AccessToken请求
    func loadAccessToken(parameters: [String: AnyObject], completion: (response: Response<AnyObject, NSError>) -> Void) {
        // 1.准备请求路径
        guard let url = NSURL(string: "https://api.weibo.com/oauth2/access_token") else {
            return
        }
        
        // 2.发送POST请求
        Alamofire.request(.POST, url, parameters: parameters, encoding: .URL, headers: nil).responseJSON { (response) in
            completion(response: response)
        }
    }
    
    /// 获取用户信息请求
    func loadUserInfo(parameters: [String: AnyObject], completion: (response: Response<AnyObject, NSError>) -> Void)  {
        // 1.准备请求路径
        guard let url = NSURL(string: "https://api.weibo.com/2/users/show.json") else {
            QL1("用户信息请求路径失效")
            return
        }
        
        // 2.发送GET请求
        Alamofire.request(.GET, url, parameters: parameters, encoding: .URL, headers: nil).responseJSON { (response) in
           completion(response: response)
        }
    }
    
    /// 获取当前登录用户及其所关注（授权）用户的最新微博
    func loadStatuses(completion: (response: Response<AnyObject, NSError>) -> Void){
        assert(RequestAccount.loadUserAccount() != nil, "必须先授权之后才能获取用户微博数据")
        
        guard let url = NSURL(string: "https://api.weibo.com/2/statuses/home_timeline.json") else {
            return
        }
        
        let parameters = ["access_token": RequestAccount.loadUserAccount()!.access_token!]
        
        Alamofire.request(.GET, url, parameters: parameters, encoding: .URL, headers: nil).responseJSON { (response) in
            completion(response: response)
        }
    }
    
}
