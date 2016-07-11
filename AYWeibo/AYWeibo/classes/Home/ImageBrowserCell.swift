//
//  ImageBrowserCell.swift
//  AYWeibo
//
//  Created by Kinyong on 16/7/11.
//  Copyright © 2016年 Ayong. All rights reserved.
//

import UIKit
import SDWebImage

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
    
    var bmiddle_url: NSURL? {
        didSet {
            // 设置图片
            imageView.sd_setImageWithURL(bmiddle_url) { (image, _, _, _) in
                let width = UIScreen.mainScreen().bounds.width
                let height = UIScreen.mainScreen().bounds.height
                
                // 1.计算当前图片的宽高比
                let scale = image.size.height / image.size.width
                
                // 2.利用宽高比乘以屏幕宽度，等比缩放图片
                let imageHeight = scale * width
                
                // 3.设置图片frame
                self.imageView.frame = CGRect(origin: CGPointZero, size: CGSize(width: width, height: imageHeight))
                
                // 4.计算滚动视图的顶部和底部的内边距
                let offsetY = (height - imageHeight) * 0.5
                
                // 5.设置内边距
                if imageHeight < height {
                    // 小图
                    self.scrollView.contentInset = UIEdgeInsets(top: offsetY, left: 0, bottom: offsetY, right: 0)
                    
                } else if imageHeight > height {
                    // 大图
                    self.scrollView.contentSize = CGSizeMake(width, imageHeight)
                    
                }
            }
        }
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
        scrollView.frame = self.bounds
        scrollView.backgroundColor = UIColor.greenColor()
    }
    
    
}
