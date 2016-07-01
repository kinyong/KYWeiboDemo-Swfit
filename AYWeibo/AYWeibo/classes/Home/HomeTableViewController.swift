//
//  HomeTableViewController.swift
//  AYWeibo
//
//  Created by Ayong on 16/5/19.
//  Copyright © 2016年 Ayong. All rights reserved.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "HomeCell"
private let reuseIdentifierForward = "ForwardCell"

class HomeTableViewController: BaseViewController {
    
    /// 导航条标题按钮
    private lazy var titleButton: UIButton = {
        let btn = TitleButton()
        let title = RequestAccount.loadUserAccount()?.screen_name
        btn.setTitle(title, forState: .Normal)
        btn.addTarget(self, action: #selector(self.titleBtnClick(_:)), forControlEvents: .TouchUpInside)
        
        return btn
    }()
    
    /// 保存所有微博数据
    private var statuses: [StatuseViewModel]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    /// 缓存cell的行高
    private var rowHeightCache = [String: CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.判断用户是否登录
        if !isLogin {
            // 设置访客视图
            visitorView?.setupVisitorInfo(nil, title: "关注一些人，回这里看看有什么惊喜")
            return
        }
        
        // 2.初始化导航条按钮
        setupNavigationBar()
        
        // 3.注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.titleChange), name: AYTransitioningManagerPresented, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.titleChange), name: AYTransitioningManagerDismissed, object: nil)
        
        // 4.加载当前登录用户及其所关注（授权）用户的最新微博
        loadStatusesData()
        
        // 5.创建cell并注册标示符
        self.tableView.registerNib(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.tableView.registerNib(UINib(nibName: "ForwardTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifierForward)
        self.tableView.separatorStyle = .None
    }
    
    deinit {
        // 移除通知
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 释放缓存数据
        rowHeightCache.removeAll()
    }
    
    // MARK: tableViewDataSurce
 
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = (statuses![indexPath.row].forward_content_text != nil) ? reuseIdentifierForward : reuseIdentifier
        // 1.获取cell
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! HomeTableViewCell
        // 2.设置数据
        cell.viewModel = statuses?[indexPath.row]
        // 3.返回cell
        return cell
    }
    
    // MARK: - tableviewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let viewModel = statuses![indexPath.row]
        let identifier = (statuses![indexPath.row].forward_content_text != nil) ? reuseIdentifierForward : reuseIdentifier
        
        // 1.如果缓存中有值
        guard let height = rowHeightCache[viewModel.statuse.idstr ?? "-1"] else {
            // 2.如果缓存中没有值
            // 2.1 获取当前显示的cell
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! HomeTableViewCell
            // 2.2 计算行高
            let rowHeigth = cell.calculateRowHeight(statuses![indexPath.row])
            // 2.3 缓存行高
            rowHeightCache[viewModel.statuse.idstr ?? "-1"] = rowHeigth
            // 2.4 返回行高
            return rowHeigth
        }
        
        // 1.1 返回缓存中的行高
        return height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 1000
    }
    
    // MARK: - 内部控制方法
    
    // 加载当前登录用户及其所关注（授权）用户的最新微博
    private func loadStatusesData() {
        NetWorkTools.shareIntance.loadStatuses { (response) in
            // 1.获取网络数据
            guard let data = response.data else {
                QL2("获取网络数据失败")
                return
            }
            
            // 2.json转字典
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as! [String: AnyObject]
                
                // 3.字典转模型
                var models = [StatuseViewModel]()

                guard let arr = dict["statuses"] as? [[String: AnyObject]] else {
                    QL2("提取数据失败")
                    return
                }
                
                for dict in arr {
                    let statuse = StatuseModel(dict: dict)
                    models.append(StatuseViewModel(statuse: statuse))
                }
                
                // 3.1 缓存图片
                self.cacheImage(models)
            
            } catch {
                QL2("json解析失败")
            }
        }
    }
    
//     3.1 缓存图片方法实现
    private func cacheImage(viewModels: [StatuseViewModel]) {
        // 0.创建一个队列组
        let group = dispatch_group_create()

        for viewModel in viewModels {
            
            // 1.从模型数据中取出配图数组
            guard let urls = viewModel.thumbnail_urls else {
                continue
            }
            
            // 2.遍历配图数组利用SDWebImage下载图片
            for url in urls {
                dispatch_group_enter(group)
                
                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (image, error, _, _, _) in
                    dispatch_group_leave(group)

                })

            }
        }
        // 3.2 存储模型 - 监听缓存图片下载完成
        dispatch_group_notify(group, dispatch_get_main_queue(), {
            self.statuses = viewModels
        })
        
        
    }
    
    // 接收到通知后的实现方法
    @objc private func titleChange() {
        titleButton.selected = !titleButton.selected
    }
    
    private func setupNavigationBar() {
        // 1. 添加左右按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(imageName: "navigationbar_friendattention",
                                                           target: self,
                                                           action: #selector(self.leftBarButtonItemClick))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(imageName: "navigationbar_pop",
                                                            target: self,
                                                            action: #selector(self.rightBarButtonItemClick))
        
        // 2. 添加标题按钮
        navigationItem.titleView = titleButton
    }
    
    // 标题按钮监听方法
    @objc private func titleBtnClick(sender: TitleButton){
        QL2("")
        // 1.modal控制器
        // 1.1 获取storyboard
        let sb = UIStoryboard(name: "Popover", bundle: nil)
        
        // 1.2 获取控制器
        guard let presentControl = sb.instantiateInitialViewController() else {
            QL2("获取控制器失败")
            return
        }
        
        // 1.3 modal控制器
        self.presentViewController(presentControl, animated: true, completion: nil)
    }
    
    /// 左侧导航条按钮监听方法
    @objc private func leftBarButtonItemClick() {
        QL2("")
    }
    
    /// 右侧导航条按钮监听方法
    @objc private func rightBarButtonItemClick() {
        QL2("")
        let nav = UINavigationController(rootViewController: QRCordViewController())
        nav.navigationBar.barTintColor = UIColor.blackColor()
        nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        presentViewController(nav, animated: true, completion: nil)
    }
    
}


