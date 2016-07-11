//
//  ImageBrowserCell.swift
//  AYWeibo
//
//  Created by Kinyong on 16/7/11.
//  Copyright © 2016年 Ayong. All rights reserved.
//

import UIKit

class ImageBrowserCell: UICollectionViewCell {
    
    // MARK: - 懒加载
    lazy var scrollView: UIScrollView = UIScrollView()
    lazy var imageView: UIImageView = UIImageView()
    
    // MARK: - 系统内部方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 初始化UI
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 内部方法
    
    private func setupUI() {
        // 1.添加子控件
        self.contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        // 2.布局子控件
        scrollView.frame = self.frame
        scrollView.backgroundColor = UIColor.greenColor()
    }
    
    
}
