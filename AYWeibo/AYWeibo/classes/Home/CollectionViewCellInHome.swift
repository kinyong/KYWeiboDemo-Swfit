//
//  CollectionViewCellInHome.swift
//  AYWeibo
//
//  Created by Kinyong on 16/6/30.
//  Copyright © 2016年 Ayong. All rights reserved.
//

import UIKit
import SDWebImage

class CollectionViewCellInHome: UICollectionViewCell {
    /// 显示微博图片
    private lazy var picImageView: UIImageView = UIImageView()
    
    var url: NSURL? {
        didSet {
            picImageView.sd_setImageWithURL(url)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        picImageView.contentMode = .ScaleAspectFill
        picImageView.clipsToBounds = true
        contentView.addSubview(picImageView)
        setupConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraint() {
        picImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[picImageView]-0-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["picImageView": picImageView]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[picImageView]-0-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["picImageView": picImageView]))
    }
}
