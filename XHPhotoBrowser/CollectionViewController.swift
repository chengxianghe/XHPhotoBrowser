//
//  CollectionViewController.swift
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/23.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

var caption = ["",
               "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
               "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book",
               "It has survived not only five centuries, but also the leap into electronic typesetting",
               "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen bookLorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen bookremaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
               "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
               "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
               "It has survived not only five centuries, but also the leap into electronic typesetting",
               "remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
               "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
               "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
               "It has survived not only five centuries, but also the leap into electronic typesetting",
               "remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
]

var imageurls: [[String : AnyObject]] = {
    return NSArray.init(contentsOfFile: NSBundle.mainBundle().pathForResource("imagesModels", ofType: "plist")!) as! [[String : AnyObject]]
}()

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private final let screenBound = UIScreen.mainScreen().bounds
    private var screenWidth: CGFloat { return screenBound.size.width }
    private var screenHeight: CGFloat { return screenBound.size.height }
        
    @IBOutlet weak var collectionView: UICollectionView!
    var images = [ImageModel]()
    let switcher = UISwitch()
    let leftsSwitcher = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        switcher.on = true
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: switcher), UIBarButtonItem.init(title: "虚化", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)]
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem.init(customView: leftsSwitcher), UIBarButtonItem.init(title: "下标", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)]

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            for dict in imageurls {
                let model = ImageModel()
                model.setValuesForKeysWithDictionary(dict)
//                model.caption = caption[random()%10]
                
                self.images.append(model)
                
                if self.images.count == 30 {
                    break
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.reloadData()
            })
        })
        
        
    }
    
    private func setupTableView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("exampleCollectionViewCell", forIndexPath: indexPath) as? ExampleCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.setInfo(self.images[indexPath.row].small)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //启动图片浏览器
        let vc = self
        
        let currentPage = indexPath.row
        
        let v = XHPhotoBrowser()
        
        print(self.collectionView.contentOffset.y)
        v.thumbViewIsCell = true
        v.contentOffSetY = self.collectionView.contentOffset.y
        v.delegate = self
        v.dataSource = self
        v.showDeleteButton = true
        v.showCloseButton = false
        v.toolBarShowStyle = leftsSwitcher.on ? .Auto : .Hide
        v.fromItemIndex = currentPage
        v.blurEffectBackground = self.switcher.on
        v.showInContaioner(vc.tabBarController!.view, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return CGSize(width: screenWidth/2 - 5, height: 300)
        } else {
            return CGSize(width: screenWidth/3 - 10, height: screenWidth/3 - 10)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    
}

class MYPhotoGroupItem: XHPhotoGroupItem {
    override var thumbImage: UIImage? {
        get {
            if self.thumbView != nil {
                return (self.thumbView as! ExampleCollectionViewCell).exampleImageView.image
            }
            return nil
        }
    }
}

extension CollectionViewController: XHPhotoBrowserDataSource {
    func xh_numberOfImagesInPhotoBrowser(photoBrowser: XHPhotoBrowser) -> Int {
        return self.images.count
    }
    
    func xh_photoBrowser(photoBrowser: XHPhotoBrowser, photoAtIndex index: Int) -> XHPhotoProtocol {
        let item = MYPhotoGroupItem()
        let indexPaths = collectionView.indexPathsForVisibleItems()
        for indexP in indexPaths {
            if index == indexP.row {
                item.thumbView = (self.collectionView(self.collectionView, cellForItemAtIndexPath: indexP) as! ExampleCollectionViewCell)
                break
            }
        }
        
        item.caption = self.images[index].caption
        
        item.largeImageURL = NSURL(string: images[index].big)
        if item.thumbView != nil {
            item.shouldClipToTop = self.shouldClippedToTop((item.thumbView as! ExampleCollectionViewCell).exampleImageView)
        } else {
            item.shouldClipToTop = false
        }
//        item.shouldClipToTop = self.shouldClippedToTop(item.thumbView)
        return item
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


extension CollectionViewController: XHPhotoBrowserDelegate {
    
    func xh_photoBrowserWillMoveToSuperView(photoBrowser: XHPhotoBrowser) {
        let viscells = self.collectionView.visibleCells()
        let viscellIndexs = self.collectionView.indexPathsForVisibleItems()
        let index = photoBrowser.fromItemIndex
        for (i, indexPath) in viscellIndexs.enumerate() {
            if indexPath.item == index {
                viscells[i].hidden = true
                break
            }
        }

    }
    
    func xh_photoBrowserWillRemoveFromSuperView(photoBrowser: XHPhotoBrowser) {
        let viscells = self.collectionView.visibleCells()
        viscells.forEach({$0.hidden = false})

//        let viscellIndexs = self.collectionView.indexPathsForVisibleItems()
//        let index = photoBrowser.currentPage
//        for (i, indexPath) in viscellIndexs.enumerate() {
//            if indexPath.item == index {
//                viscells[i].hidden = false
//                break
//            }
//        }

    }
    
    func xh_photoBrowser(photoBrowser: XHPhotoBrowser, didDisplayingImageAtIndex index: Int, fromIndex: Int) {
        print("正在展示第 \(index) 页 , fromIndex:\(fromIndex)")
        
        let viscells = self.collectionView.visibleCells()
        let viscellIndexs = self.collectionView.indexPathsForVisibleItems()
        
        for (i, indexPath) in viscellIndexs.enumerate() {
            if indexPath.item == index {
               viscells[i].hidden = true
                break
            }
        }

        if fromIndex != NSNotFound {
            for (i, indexPath) in viscellIndexs.enumerate() {
                if indexPath.item == fromIndex {
                    viscells[i].hidden = false
                    break
                }
            }
        }

    }
}




class ExampleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var exampleImageView: UIImageView!
    
    func setInfo(url: String) {
        let imageView = self.exampleImageView

        imageView.layer.removeAnimationForKey("contents")
        imageView.yy_setImageWithURL(NSURL(string: url)!, placeholder: UIImage(named: "whiteplaceholder"), options: YYWebImageOptions.AvoidSetImage, progress: nil, transform: nil, completion: {[weak imageView] (image, url, from, stage, error) in
                
                // if (image != nil && stage == YYWebImageStage.Finished) {
                //     imageView.image = image;
                // }
                guard let imageView = imageView else {
                    return
                }
                
                if (error != nil || image == nil) {
                    imageView.image = UIImage(named: "whiteplaceholder")
                    return ;
                }
                
                imageView.image = image;
                
                let width = image!.size.width * UIScreen.mainScreen().scale
                let height = image!.size.height * UIScreen.mainScreen().scale
                //
                let scale = (height / width) / (imageView.bounds.size.height / imageView.bounds.size.width);
                if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                    imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    imageView.layer.contentsRect = CGRectMake(0, 0, 1, 1)
                } else { // 高图只保留顶部
                    imageView.contentMode = UIViewContentMode.ScaleToFill;
                    imageView.layer.contentsRect = CGRectMake(0, 0, 1, width / height);
                }
            
                if (from != YYWebImageFromType.MemoryCacheFast) {
                    let transition = CATransition()
                    transition.duration = 0.15;
                    transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut);
                    transition.type = kCATransitionFade;
                    imageView.layer.addAnimation(transition, forKey: "contents")
                }
                
            })

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        exampleImageView.image = nil
        exampleImageView.contentMode = UIViewContentMode.ScaleAspectFill
//        layer.cornerRadius = 25.0
//        layer.masksToBounds = true
    }
    
//    override func prepareForReuse() {
//        exampleImageView.image = nil
//    }
}

