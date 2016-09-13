//
//  XHPhotoGroup.swift
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/14.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class XHPhotoItem: NSObject {
    /// 缩略图
    var thumbnail_pic = ""
    
    /// 原图
    var original_pic = ""
    
    /// size
    var photoSize = CGSizeZero
}

class XHPhotoGroup: UIView {

    private var imageViews = [UIImageView]()
    
    var photoItemArray: [XHPhotoItem]? {
        didSet {
            setupPhotoData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPhotoGroup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPhotoGroup()
    }
    
    func setupPhotoGroup() {
        for _ in 0..<9 {
            let imageView = UIImageView()
            imageView.contentMode = .ScaleAspectFill
            imageView.clipsToBounds = true
            imageView.userInteractionEnabled = true
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapImage(_:)))
            imageView.addGestureRecognizer(tap)
            self.addSubview(imageView)
            imageViews.append(imageView)
        }
    }
    
    func setupPhotoData() {        
        // 刷新图片布局
        self.setFrameSubviews()
        // 刷新图片数据
        self.setPhotoGroupImage()

    }
    
    func setFrameSubviews() {
        let array = PhotoViewFrameHelper.getPhotoViewFramesWithPhotoCount(photoItemArray?.count ?? 0, photoViewSize: self.frame.size, gap: 10)
        
        let enumer = imageViews.enumerate()
        for (index, imageView) in enumer {
            if index < array.count {
                imageView.frame = CGRectFromString(array[index])
            } else {
                imageView.frame = CGRectZero;
            }
        }
    }
    
    func setPhotoGroupImage() {
        
        let enumer = imageViews.enumerate()
        for (index, imageView) in enumer {
            if index >= photoItemArray?.count {
                imageView.image = nil;
                return
            }
            
            imageView.layer.removeAnimationForKey("contents")
            
            let photoItem = photoItemArray![index]
            
            imageView.yy_setImageWithURL(NSURL(string: photoItem.original_pic)!,
                                         placeholder: UIImage(named: "whiteplaceholder"),
                                         options: YYWebImageOptions.AvoidSetImage,
                                         progress: nil,
                                         transform: nil,
                                         completion: {[weak imageView] (image, url, from, stage, error) in

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
//                                                imageView.alignTop = false
                                                imageView.contentMode = UIViewContentMode.ScaleAspectFill;
                                                imageView.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                                            } else { // 高图只保留顶部
//                                                imageView.alignTop = true
                                                imageView.contentMode = UIViewContentMode.ScaleToFill;
                                                let imageViewScale = imageView.bounds.size.width / imageView.bounds.size.height
                                                imageView.layer.contentsRect = CGRectMake(0, 0, 1, width / height / imageViewScale);
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

    }
    
    func tapImage(sender: UITapGestureRecognizer) {
        //启动图片浏览器
        let vc = self.xh_viewController
        let currentPage = imageViews.indexOf(sender.view as! UIImageView) ?? 0

        var items = [XHPhotoGroupItem]()
        let enumer = photoItemArray!.enumerate()
        
        for (index, photoItem) in enumer {
            let item = XHPhotoGroupItem()
            item.thumbView = imageViews[index]
            item.largeImageURL = NSURL(string: photoItem.original_pic)
            item.shouldClipToTop = self.shouldClippedToTop(item.thumbView)
            item.caption = caption[random()%10];
            items.append(item)
        }

        let v = XHPhotoBrowser.init(groupItems: items)
        v.delegate = self
        v.fromItemIndex = currentPage
        v.blurEffectBackground = false
        v.toolBarShowStyle = .Auto
        v.pager.hidesForSinglePage = true
//        v.showToolBarWhenScroll = false
//        v.showCaptionWhenScroll = false
        v.showInContaioner(vc.tabBarController!.view, animated: true, completion: nil)

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

extension XHPhotoGroup: XHPhotoBrowserDelegate {
    
    func xh_photoBrowserWillMoveToSuperView(photoBrowser: XHPhotoBrowser) {
        let index = photoBrowser.fromItemIndex
        self.imageViews[index].hidden = true
    }
    
    func xh_photoBrowserWillRemoveFromSuperView(photoBrowser: XHPhotoBrowser) {
        let index = photoBrowser.currentPage
        self.imageViews[index].hidden = false
    }
    
    func xh_photoBrowserWillDisplay(photoBrowser: XHPhotoBrowser) {
        print("将要展示")

    }
    
    func xh_photoBrowserDidDisplay(photoBrowser: XHPhotoBrowser) {
        print("已经展示")
    }
    
    func xh_photoBrowserWillDismiss(photoBrowser: XHPhotoBrowser) {
        print("将要消失")
    }
    
    func xh_photoBrowserDidDismiss(photoBrowser: XHPhotoBrowser) {
        print("已经消失")
    }
    
    func xh_photoBrowser(photoBrowser: XHPhotoBrowser, didDisplayingImageAtIndex index: Int, fromIndex: Int) {
        print("正在展示第 \(index) 页 , fromIndex:\(fromIndex)")
        if fromIndex != NSNotFound {
            self.imageViews[fromIndex].hidden = false
        }
        self.imageViews[index].hidden = true

    }
}


