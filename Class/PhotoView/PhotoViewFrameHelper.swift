//
//  PhotoViewFrameHelper.swift
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/15.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

private let screenW = UIScreen.mainScreen().bounds.size.width
private let TEXT_WIDTH: CGFloat = screenW - 20
private let radio1: CGFloat = 116 / 154.0
private let radio2: CGFloat = 176 / 236.0

class PhotoViewFrameHelper: NSObject {
    
    // 默认宽度
    
    // 9宫格
    private static func kPhotoWidth1(width: CGFloat, gap: CGFloat) -> CGFloat {
        return (width - 2 * gap) / 3.0
    }
    // 田字格
    private static func kPhotoWidth2(width: CGFloat, gap: CGFloat) -> CGFloat {
        return (width - gap) / 2.0
    }
    
    /**
     *  计算 布局 和 frame
     */
    static func getPhotoViewFramesWithPhotoCount(count: NSInteger, photoViewSize: CGSize, gap: CGFloat) -> [String] {
        if (count <= 0) {
            return [];
        }
        
        if (count == 1) {
            let photoWidth = (photoViewSize.width - gap) / 2.0;
            return [NSStringFromCGRect(CGRectMake(0, 0, photoWidth, photoViewSize.height))];
        }
        
        var array = [String]();
        
        var onePhotoSize = CGSizeZero;
        var columns: Int = 0;
        var row: Int = 0;
        
        if (count == 2 || count == 4) {
            // 2/4 张， 单张比例 高度/宽度
            let photoWidth = (photoViewSize.width - gap) / 2.0;
            onePhotoSize = CGSizeMake(photoWidth, photoWidth * radio2);
            columns = 2;
        } else {
            // 单张比例 高度/宽度 9宫格
            let photoWidth = (photoViewSize.width - 2 * gap) / 3.0;
            onePhotoSize = CGSizeMake(photoWidth, photoWidth * radio1);
            columns = 3;
        }

        for i in 0..<count {
            row = i / columns;
            let col = i % columns;
            let x = CGFloat(col) * (onePhotoSize.width + gap);
            let y = CGFloat(row) * (onePhotoSize.height + gap);
            
            let frame = CGRectMake(x, y, onePhotoSize.width, onePhotoSize.height);
            
            array.append(NSStringFromCGRect(frame))
        }
        
        return array;
    }
    
    /**
     *  获取整个PhotoView的size
     */
    static func getPhotoViewSizeWithPhotoCount(count: NSInteger, gap: CGFloat) -> CGSize {
        // 一行最多有3列
        var photoViewSize = CGSizeZero;
        
        // 单张比例 高度/宽度 9宫格
        let  photoSize1 = CGSizeMake(kPhotoWidth1(TEXT_WIDTH, gap: gap), self.kPhotoWidth1(TEXT_WIDTH, gap: gap) * radio1);
        
        // 2/4 张， 单张比例 高度/宽度
        let  photoSize2 = CGSizeMake(kPhotoWidth2(TEXT_WIDTH, gap: gap), kPhotoWidth2(TEXT_WIDTH, gap: gap) * radio2);
        
        photoViewSize.width = TEXT_WIDTH;
        
        
        switch (count) {
        case 0:
            return CGSizeZero;
        case 1:
            fallthrough
        case 2:
            // 固定
            photoViewSize.height = photoSize2.height;
        case 3:
            photoViewSize.height = photoSize1.height;
        case 4:
            photoViewSize.height = photoSize2.height * 2 + gap;
        case 5:
            fallthrough
        case 6:
            photoViewSize.height = photoSize1.height * 2 + gap;
        default:
            photoViewSize.height =  photoSize1.height * 3 + 2 * gap;
        }
        
        return photoViewSize;

    }

}
