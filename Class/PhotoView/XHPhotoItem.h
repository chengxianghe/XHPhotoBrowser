//
//  XHPhotoItem.h
//  GMBuy
//
//  Created by chengxianghe on 15/9/21.
//  Copyright © 2015年 cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XHPhotoItem : NSObject

@property (nonatomic, copy) NSString *thumbnail_pic;    // 缩略图
@property (nonatomic, copy) NSString *original_pic;     // 原图
@property (nonatomic, assign) CGSize photoSize;

@end
