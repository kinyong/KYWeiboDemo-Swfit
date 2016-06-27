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
    
    private func setupSubViews() {
        iconImageView.layer.cornerRadius = 25.0
        iconImageView.layer.borderWidth = 1.0
        iconImageView.layer.borderColor = UIColor.grayColor().CGColor
        iconImageView.clipsToBounds = true
    }
    
}
