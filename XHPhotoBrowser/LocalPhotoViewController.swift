//
//  LocalPhotoViewController.swift
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/10.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit


class ImageModel: NSObject {
    var small = ""
    var big = ""
    var middle = ""
    var caption = ""
}

class LocalPhotoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var dataSource = Array<[XHPhotoItem]>()
    deinit {
        print("LocalPhotoViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.statusBarOrientationChange(_:)), name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        
        self.loadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
    
    func statusBarOrientationChange(notification: NSNotification) {
        self.tableView.reloadData()
//        let orientation = UIApplication.sharedApplication().statusBarOrientation
    }
    
    func loadData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //这里写需要大量时间的代码
            let imageurls = NSArray.init(contentsOfFile: NSBundle.mainBundle().pathForResource("imagesModels", ofType: "plist")!) as! [[String : AnyObject]]
            
            var modelArray = [ImageModel]()
            
            for dict in imageurls {
                let model = ImageModel()
                model.setValuesForKeysWithDictionary(dict)
                modelArray.append(model)
            }
            
            let total: Int = modelArray.count
            var i: Int = 0
            
            while i < total {
                var count = Int(random()%8) + 1
                if i + count > total  {
                    count = total - i
                }
                
                let tempArr = (modelArray as NSArray).subarrayWithRange(NSMakeRange(i, count)) as! [ImageModel]
                
                i = i + count

                let items: [XHPhotoItem] = tempArr.map({
                    let photo = XHPhotoItem()
                    photo.thumbnail_pic = $0.small
                    photo.original_pic = $0.big
                    photo.photoSize = CGSizeMake(100, 100)
                    return photo
                })
                
                self.dataSource.append(items)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                //这里返回主线程，写需要主线程执行的代码
                //                let random = Int(arc4random_uniform(UInt32(testString.length)))
                //                self.detailText = (testString as NSString).substringToIndex(random)
                self.tableView.reloadData()
            })
        })

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("PhotoTableViewCell") as? PhotoTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setInfo(self.dataSource[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let array = self.dataSource[indexPath.row]
        
        return PhotoTableViewCell.height(array)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
    }
    
    
        func shouldClippedToTop(view: UIView?) -> Bool {
            if (view != nil) {
                if (view!.layer.contentsRect.size.height < 1) {
                    return true;
                }
            }
            return false;
        }
    
}


class PhotoTableViewCell: UITableViewCell {
    
    var photosView = XHPhotoGroup()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.photosView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(self.photosView)
//        self.backgroundColor = UIColor.redColor()
    }
    
    func setInfo(images: [XHPhotoItem]) {
        self.photosView.frame = CGRectMake(10, 10, UIScreen.mainScreen().bounds.width - 20, PhotoTableViewCell.height(images) - 20);
        self.photosView.photoItemArray = images
    }
    
    static func height(images: [XHPhotoItem]) -> CGFloat {
        let h = PhotoViewFrameHelper.getPhotoViewSizeWithPhotoCount(images.count, gap: 10).height + 20
        return h
    }
    
}