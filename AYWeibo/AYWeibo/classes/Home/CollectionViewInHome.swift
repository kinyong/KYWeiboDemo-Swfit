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
    var thumbnail_urls: [NSURL?]? {
        didSet {
            self.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerClass(CollectionViewCellInHome.self, forCellWithReuseIdentifier:"CollectionViewCellInHome")
        //        self.delegate = self
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