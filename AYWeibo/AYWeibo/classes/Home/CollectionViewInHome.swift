//
//  CollectionViewInHomeCell.swift
//  AYWeibo
//
//  Created by Kinyong on 16/6/30.
//  Copyright © 2016年 Ayong. All rights reserved.
//

import UIKit
import SDWebImage

class CollectionViewInHome: UICollectionView {

       
    /// 配图地址
    var thumbnail_urls: [NSURL]? {
        didSet {
            self.reloadData()
        }
    }
    
    /// 大图图片地址
    var bmiddle_urls: [NSURL]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerClass(CollectionViewCellInHome.self, forCellWithReuseIdentifier:"CollectionViewCellInHome")
        self.delegate = self
        self.dataSource = self
    }
}

// MARK: - dataSource
extension CollectionViewInHome: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 如果有返回count，如果没有返回0即没有显示item
        return thumbnail_urls?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCellInHome", forIndexPath: indexPath) as! CollectionViewCellInHome
        
        cell.url = thumbnail_urls![indexPath.item]
        
        cell.backgroundColor = UIColor.redColor()
        
        return cell
    }
}

// MARK: -delegate
extension CollectionViewInHome: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // 当点击首页cell的缩略图时候，通知首页控制器进行modle显示图片浏览
        NSNotificationCenter.defaultCenter().postNotificationName(KYHomeCellShowImageView, object: self, userInfo: ["bmiddle_urls": bmiddle_urls!, "indexPath": indexPath])
    }
}