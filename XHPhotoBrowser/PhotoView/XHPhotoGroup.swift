//
//  XHPhotoGroup.swift
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/14.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class XHPhotoGroupItem: NSObject {
    /// 缩略图
    var thumbnail_pic = ""
    
    /// 原图
    var original_pic = ""
    
    /// size
    var photoSize = CGSize.zero
}
typealias XHPhotoGroupShowClosure = (XHPhotoBrowser) -> (Void)

class XHPhotoGroup: UIView {

    fileprivate var imageViews = [UIImageView]()
    
    var photoBrowserDidShowClosure: XHPhotoGroupShowClosure?
    var photoBrowserDidDismissClosure: XHPhotoGroupShowClosure?
    
    var photoItemArray: [XHPhotoGroupItem]? {
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
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapImage(sender:)))
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
        let array = PhotoViewFrameHelper.getPhotoViewFramesWithPhotoCount(count: photoItemArray?.count ?? 0, photoViewSize: self.frame.size, gap: 10)
        
        let enumer = imageViews.enumerated()
        for (index, imageView) in enumer {
            if index < array.count {
                imageView.frame = CGRectFromString(array[index])
            } else {
                imageView.frame = CGRect.zero;
            }
        }
    }
    
    func setPhotoGroupImage() {
        
        let enumer = imageViews.enumerated()
        for (index, imageView) in enumer {
            if index >= photoItemArray?.count ?? 0 {
                imageView.image = nil;
                return
            }
            
            imageView.layer.removeAnimation(forKey: "contents")
            
            let photoItem = photoItemArray![index]
            
            imageView.yy_setImage(with: NSURL(string: photoItem.original_pic)! as URL,
                                         placeholder: UIImage(named: "whiteplaceholder"),
                                         options: YYWebImageOptions.avoidSetImage,
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
                                            
                                            let width = image!.size.width * UIScreen.main.scale
                                            let height = image!.size.height * UIScreen.main.scale
                                            //
                                            let scale = (height / width) / (imageView.bounds.size.height / imageView.bounds.size.width);
                                            if (scale < 0.99 || scale.isNaN) { // 宽图把左右两边裁掉
//                                                imageView.alignTop = false
                                                imageView.contentMode = UIViewContentMode.scaleAspectFill;
                                                imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1);
                                            } else { // 高图只保留顶部
//                                                imageView.alignTop = true
                                                imageView.contentMode = UIViewContentMode.scaleToFill;
                                                let imageViewScale = imageView.bounds.size.width / imageView.bounds.size.height
                                                imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: width / height / imageViewScale);
                                            }
                                            
                                            if (from != YYWebImageFromType.memoryCacheFast) {
                                                let transition = CATransition()
                                                transition.duration = 0.15;
                                                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut);
                                                transition.type = kCATransitionFade;
                                                imageView.layer.add(transition, forKey: "contents")
                                            }
        
            })
            
        }

    }
    
    @objc func tapImage(sender: UITapGestureRecognizer) {
        //启动图片浏览器
        let vc = self.xh_viewController
        let currentPage = imageViews.index(of: sender.view as! UIImageView) ?? 0

        var items = [XHPhotoItem]()
        let enumer = photoItemArray!.enumerated()
        
        for (index, photoItem) in enumer {
            let item = XHPhotoItem()
            item.thumbView = imageViews[index]
            item.largeImageURL = URL(string: photoItem.original_pic)
            item.shouldClipToTop = self.shouldClippedToTop(view: item.thumbView)
            item.caption = caption[Int(arc4random())%10];
            items.append(item)
        }

        let v = XHPhotoBrowser.init(groupItems: items)
        v.delegate = self
        v.fromItemIndex = currentPage
        v.blurEffectBackground = false
        v.hideToolBar = false
        v.pager.hidesForSinglePage = true
        v.singleTapOption = .dismiss
//        v.showToolBarWhenScroll = false
//        v.showCaptionWhenScroll = false
        
        //iPhone X上可以设置额外的选项
        v.isFullScreenWord = false
        v.isFullScreen = true
        
        v.show(inContaioner: (vc?.tabBarController!.view)!, animated: true, completion: nil)

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
    
    func xh_photoBrowserWillMove(toSuperView photoBrowser: XHPhotoBrowser) {
        let index = photoBrowser.fromItemIndex
        self.imageViews[index].isHidden = true
    }
    
    func xh_photoBrowserWillRemove(fromSuperView photoBrowser: XHPhotoBrowser) {
        let index = photoBrowser.currentPage
        self.imageViews[index].isHidden = false
    }
    
    func xh_photoBrowserWillDisplay(_ photoBrowser: XHPhotoBrowser) {
        print("将要展示")
    }
    
    func xh_photoBrowserDidDisplay(_ photoBrowser: XHPhotoBrowser) {
        print("已经展示")
        photoBrowserDidShowClosure?(photoBrowser)
    }
    
    func xh_photoBrowserWillDismiss(_ photoBrowser: XHPhotoBrowser) {
        print("将要消失")
    }
    
    func xh_photoBrowserDidDismiss(_ photoBrowser: XHPhotoBrowser) {
        print("已经消失")
        photoBrowserDidDismissClosure?(photoBrowser)
    }
    
    func xh_photoBrowser(_ photoBrowser: XHPhotoBrowser, didDisplayingImageAt index: Int, from fromIndex: Int) {
        print("正在展示第 \(index) 页 , fromIndex:\(fromIndex)")
        if fromIndex != NSNotFound {
            self.imageViews[fromIndex].isHidden = false
        }
        self.imageViews[index].isHidden = true

    }
}


