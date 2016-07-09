//
//  ImageBrowserViewController.swift
//  AYWeibo
//
//  Created by Kinyong on 16/7/9.
//  Copyright © 2016年 Ayong. All rights reserved.
//

import UIKit

class ImageBrowserViewController: UIViewController {
    /// 大图图片地址
    var bmiddle_urls: [NSURL]
    
    /// 索引
    var indexPath: NSIndexPath
    
    
    init(bmiddle_urls: [NSURL], indexPath: NSIndexPath ) {
        self.bmiddle_urls = bmiddle_urls
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        QL3(indexPath)
        QL3(bmiddle_urls)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
