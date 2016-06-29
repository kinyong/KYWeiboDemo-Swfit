//
//  HomeTableViewCell.swift
//  AYWeibo
//
//  Created by Ayong on 16/6/23.
//  Copyright © 2016年 Ayong. All rights reserved.
//

import UIKit
import SDWebImage

class HomeTableViewCell: UITableViewCell {
    /// 头像
    @IBOutlet var iconImageView: UIImageView!
    /// 认证标志图标
    @IBOutlet var verifiedImageView: UIImageView!
    /// 会员登记图标
    @IBOutlet var vipImageView: UIImageView!
    /// 昵称
    @IBOutlet var nameLabel: UILabel!
    /// 时间
    @IBOutlet var timeLabel: UILabel!
    /// 来源
    @IBOutlet var sourceLabel: UILabel!
    /// 正文
    @IBOutlet var contentLabel: UILabel!
    
    /// 模型数据
    var viewModel: StatuseViewModel? {
        didSet {
            // 1.设置头像
            if let url = viewModel?.user_icon_url {
                iconImageView.sd_setImageWithURL(url)
            }
            
            // 2.设置认证标志图标
            verifiedImageView.image = viewModel?.user_verified_image
            
            // 3.设置会员登记图标
            vipImageView.image = viewModel?.user_vip_image
            
            // 4.设置昵称
            nameLabel.text = viewModel?.user_name_text
            
            // 5.设置时间
            timeLabel.text = viewModel?.time_string
            
            // 6.设置来源
            sourceLabel.text = viewModel?.source_text
            
            // 7.设置正文
            contentLabel.text = viewModel?.content_text
            QL2(viewModel?.user_name_text)
            QL2(viewModel?.thumbnail_urls?.count)
            QL2(calculateSize())
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSubViews()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - 内部控制方法
    
    /// 计算cell的高度和collectionview的尺寸
    /*
     图片的排列有三种：
     1张图片：图片默认宽高
     4张图片：固定宽高 90*90
     多张图片：固定宽高 90*90
    */
    private func calculateSize() -> (cellSize: CGSize, collectionSize: CGSize) {
        // 0. 获取单个viewModel的urls数量，如果没有，就返回0
        let count = viewModel?.thumbnail_urls?.count ?? 0
        
        // 1. 1张图片
        if count == 1 {
            if let url = viewModel?.thumbnail_urls?.first  {
                // 1.1 获取缓存中的图片
                let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(url!.absoluteString)
                
                return (image.size, image.size)
            }
        }
        
        let imageWidth: CGFloat = 90
        let imageHeight: CGFloat = 90
        let imageMargin: CGFloat = 10
        // 2. 四张图片
        if count == 4 {
            let row = 2
            let col = 2
            
            return getSize(imageWidth, h: imageHeight, m: imageMargin, row: row, col: col)
        }
        
        // 3. 其他张图片
        let col = 3
        let row = (count - 1) / col + 1
        return getSize(imageWidth, h: imageHeight, m: imageMargin, row: row, col: col)
    }
    
    // 获取宽高的方法
    private func getSize(w: CGFloat, h: CGFloat, m: CGFloat, row: Int, col: Int) -> (CGSize, CGSize){
        // 宽度： 列数 * 图片宽度 + (列数 - 1) * 间隙
        let width = CGFloat(col) * w + CGFloat(col - 1) * m
        // 高度：行数 * 图片宽度 + （行数 - 1）* 间隙
        let height = CGFloat(row) * h + CGFloat(row - 1) * m
        let cellsSize = CGSize(width: width, height: height)
        let collectionSize = CGSize(width: w, height: h)
        
        return (cellsSize, collectionSize)
    }
    
    private func setupSubViews() {
        iconImageView.layer.cornerRadius = 25.0
        iconImageView.layer.borderWidth = 1.0
        iconImageView.layer.borderColor = UIColor.grayColor().CGColor
        iconImageView.clipsToBounds = true
    }
}
