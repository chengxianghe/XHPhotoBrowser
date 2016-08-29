//
//  ViewController.swift
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/9.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func onPushBrowser(sender: AnyObject) {
        let browserVC = XHPhotoBrowserController()
        var images = [XHPhotoGroupItem]();
        
        for i in 0..<imageurls.count {
            
            let dict = imageurls[i]
            let model = ImageModel()
            model.setValuesForKeysWithDictionary(dict)
            model.caption = caption[random()%10]
            
            let item = MYPhotoGroupItem()
            item.caption = model.caption
            item.largeImageURL = NSURL(string: model.big)
            item.shouldClipToTop = false
            
            images.append(item)
            
            if images.count == 20 {
                break
            }
        }
        
        browserVC.groupItems = images;
        
        
        browserVC.moreBlock = {[weak browserVC] in
            let other = ["设置1", "设置2", "设置3"]
            let sheet = XHActionSheet(title: "more", cancelTitle: "取消", otherTitles: other)
            sheet.showInView(browserVC?.view, custom: nil, clickIndex: { (index) in
                if index == 0 {
                    print("取消")
                } else {
                    print(other[index - 1])
                }
                }, cancel: nil)
        }
        
        self.navigationController?.pushViewController(browserVC, animated: true)

        
    }
        
    @IBAction func onPush(sender: AnyObject) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "测试"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}

