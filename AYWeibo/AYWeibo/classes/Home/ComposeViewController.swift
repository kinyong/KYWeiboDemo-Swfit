//
//  ComposeViewController.swift
//  AYWeibo
//
//  Created by Jinyong on 16/7/23.
//  Copyright © 2016年 Ayong. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.添加子控件
        setupUI()
        
        // 2.布局子控件
        setupConstraints()
    }
    
    // MARK: - 内部控制方法
    func setupUI() {
        // 1.添加导航栏按钮
        let leftItem = UIBarButtonItem(title: "关闭", style: .Done, target: self, action: #selector(self.leftBarButtonClick))
        let rightItem = UIBarButtonItem(title: "发送", style: .Done, target: self, action: #selector(self.rightBarButtonClick))
        // 1.1.添加左侧导航按钮
        self.navigationItem.leftBarButtonItem = leftItem
        // 1.2.添加右侧导航按钮
        self.navigationItem.rightBarButtonItem = rightItem
        // 1.3.添加导航标题
        let titleView = JYTitleView(frame: CGRectMake(0, 0, 100, 40))
        titleView.backgroundColor = self.navigationController?.navigationBar.backgroundColor
        self.navigationItem.titleView = titleView
        
        // 2.添加文本视图
        self.view.addSubview(textView)
        
    }
    
    private func setupConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[textView]-0-|", options: .DirectionMask, metrics: nil, views: ["textView": textView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[textView]-0-|", options: .DirectionMask, metrics: nil, views: ["textView": textView]))
        
    }
    
    // 左侧导航按钮监听
    @objc private func leftBarButtonClick() {
        QL2("")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // 右侧导航按钮监听
    @objc private func rightBarButtonClick() {
        QL2("")
    }
    
    // MARK: - 懒加载
    private lazy var textView: UITextView = {
        let tv = JYTextView(frame: CGRectZero, textContainer: nil)
        tv.font = UIFont.systemFontOfSize(14)
        return tv
    }()
    
}
