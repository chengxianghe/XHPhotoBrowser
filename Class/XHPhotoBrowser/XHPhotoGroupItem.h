//
//  YYPhotoGroupItem.h
//  YYKitDemo
//
//  Created by chengxianghe on 15/12/26.
//  Copyright © 2015年 ibireme. All rights reserved.
//

/// Single picture's info.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol XHPhotoProtocol <NSObject>

@required

@property (nonatomic, strong) UIView *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, strong) NSURL *largeImageURL;
@property (nonatomic, assign) BOOL shouldClipToTop;///< 是否是长图
@property (nonatomic, readonly) UIImage *thumbImage;

@optional

@property (nonatomic, copy) NSString *caption;

@end

@interface XHPhotoGroupItem : NSObject <XHPhotoProtocol>

@property (nonatomic, strong) UIView *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, strong) NSURL *largeImageURL;
@property (nonatomic, assign) BOOL shouldClipToTop;
@property (nonatomic, readonly) UIImage *thumbImage;

@property (nonatomic, copy) NSString *caption;

@end
