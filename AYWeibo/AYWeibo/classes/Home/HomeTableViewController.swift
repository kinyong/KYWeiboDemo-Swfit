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
    private var statuses: [StatuseViewModel]?
    
    /// 缓存cell的行高
    private var rowHeightCache = [String: CGFloat]()
    
    /// 刷新提醒
    private lazy var tipLabel: UILabel = {
        let lb = UILabel()
        
        lb.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 44)
        lb.text = "没有更多的数据"
        lb.hidden = true
        lb.backgroundColor = UIColor.orangeColor()
        lb.textColor = UIColor.whiteColor()
        lb.textAlignment = .Center
        
        return lb
    }()

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
        
        // 6.设置菊花
        self.refreshControl = KYRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.loadStatusesData), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.beginRefreshing()
        
        // 7. 添加刷新提醒
        self.navigationController?.navigationBar.insertSubview(tipLabel, atIndex: 0)
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
    
    // MARK: - 内部控制方法s
    
    // 加载当前登录用户的微博
    /*
     since_id	false	int64	若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
     max_id	false	int64	若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
     默认情况下, 新浪返回的数据是按照微博ID从大到小得返回给我们的
     也就意味着微博ID越大, 这条微博发布时间就越晚
     经过分析, 如果要实现下拉刷新需要, 指定since_id为第一条微博的id
     如果要实现上拉加载更多, 需要指定max_id为最后一条微博id -1
     */

    @objc private func loadStatusesData() {
        
        // 第一次加载，idstr为nil，默认为0，初始加载20条数据，当下拉刷新时候，里面已经存放数据，就会根据idstr返回新的数据过来
        let since_id = statuses?.first?.statuse.idstr ?? "0"
        
        NetWorkTools.shareIntance.loadStatuses(since_id) { (response) in
            // 1.获取网络数据
            guard let data = response.data else {
                QL3("获取网络数据失败")
                return
            }
            
            // 2.json转字典
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as! [String: AnyObject]
                
                // 3.字典转模型
                var models = [StatuseViewModel]()
                
                guard let arr = dict["statuses"] as? [[String: AnyObject]] else {
                    QL3("提取数据失败")
                    return
                }
                
                for dict in arr {
                    let statuse = StatuseModel(dict: dict)
                    models.append(StatuseViewModel(statuse: statuse))
                }
                
                // 4. 处理微博数据(第一次刷新，下拉刷新）
                if since_id == "0" {
                    // 第一次加载
                    self.statuses = models
                } else {
                    // 下拉刷新,此时statuses里面已经有值，可以用！
                    self.statuses = models + self.statuses!
                }
                
                // 5. 缓存图片
                self.cacheImage(models)
                
            } catch {
                QL3("json解析失败")
                self.refreshControl?.endRefreshing()
            }

        }
    }
    
    // 3.1 缓存图片方法实现
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
            // 刷新表格
            self.tableView.reloadData()
            
            // 关闭下拉刷新提示
            self.refreshControl?.endRefreshing()
            
            //  显示刷新提醒数据
            self.showRefreshStatus(viewModels.count)
        })
    }
    
    // 显示刷新数据提示方法
    private func showRefreshStatus(count: Int) {
        tipLabel.text = count == 0 ? "没有更多数据" : "\(count)条数据"
        tipLabel.hidden = false
        
        UIView.animateWithDuration(0.5, animations: {
            self.tipLabel.transform = CGAffineTransformMakeTranslation(0, 44)
            }) { (bool) in
                UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions(rawValue: 0), animations: {
                    self.tipLabel.transform = CGAffineTransformIdentity
                    }, completion: { (bool) in
                        self.tipLabel.hidden = true
                })
        }
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


