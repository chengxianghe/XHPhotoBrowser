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
    var dataSource = Array<[XHPhotoGroupItem]>()
    deinit {
        print("LocalPhotoViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.statusBarOrientationChange(notification:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
        self.loadData()
    }
    
    func statusBarOrientationChange(notification: NSNotification) {
        self.tableView.reloadData()
//        let orientation = UIApplication.sharedApplication().statusBarOrientation
    }
    
    func loadData() {
        DispatchQueue.global().async {
            //这里写需要大量时间的代码
            let imageurls = NSArray.init(contentsOfFile: Bundle.main.path(forResource: "imagesModels", ofType: "plist")!) as! [[String : AnyObject]]
            
            var modelArray = [ImageModel]()
            
            for dict in imageurls {
                let model = ImageModel()
                model.setValuesForKeys(dict)
                modelArray.append(model)
            }
            
            let total: Int = modelArray.count
            var i: Int = 0
            
            while i < total {
                var count = Int(arc4random()%8) + 1
                if i + count > total  {
                    count = total - i
                }
                
                let tempArr = (modelArray as NSArray).subarray(with: NSMakeRange(i, count)) as! [ImageModel]
                
                i = i + count

                let items: [XHPhotoGroupItem] = tempArr.map({
                    let photo = XHPhotoGroupItem()
                    photo.thumbnail_pic = $0.small
                    photo.original_pic = $0.big
                    photo.photoSize = CGSize(width: 100, height: 100)
                    return photo
                })
                
                self.dataSource.append(items)
            }
            
            DispatchQueue.main.async {
                //这里返回主线程，写需要主线程执行的代码
                //                let random = Int(arc4random_uniform(UInt32(testString.length)))
                //                self.detailText = (testString as NSString).substringToIndex(random)
                self.tableView.reloadData()
            }
        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell") as? PhotoTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setInfo(images: self.dataSource[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let array = self.dataSource[indexPath.row]
        
        return PhotoTableViewCell.height(images: array)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        self.photosView.backgroundColor = UIColor.white
        self.contentView.addSubview(self.photosView)
//        self.backgroundColor = UIColor.redColor()
    }
    
    func setInfo(images: [XHPhotoGroupItem]) {
        self.photosView.frame = CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width - 20, height: PhotoTableViewCell.height(images: images) - 20)
        self.photosView.photoItemArray = images
    }
    
    static func height(images: [XHPhotoGroupItem]) -> CGFloat {
        let h = PhotoViewFrameHelper.getPhotoViewSizeWithPhotoCount(count: images.count, gap: 10).height + 20
        return h
    }
    
}
