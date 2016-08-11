//
//  PhotoViewFrameHelper.h
//  GMBuy
//
//  Created by chengxianghe on 15/9/21.
//  Copyright © 2015年 cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class XHPhotoItem;

@interface PhotoViewFrameHelper : NSObject

// 匹配 size
+ (CGSize)size:(CGSize)imageSize MatchToSize:(CGSize)maxSize;

/**
 *  计算 布局 和 frame
 */
+ (NSArray *)getPhotoViewFramesWithPhotoCount:(NSInteger)count andPhotoViewSize:(CGSize)photoSize;

/**
 *  获取整个PhotoView的size
 */
+ (CGSize)getPhotoViewSizeWithPhotoCount:(NSInteger)count;

@end
