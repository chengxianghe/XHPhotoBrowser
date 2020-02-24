//
//  XHPhotoItem.h
//  YYKitDemo
//
//  Created by chengxianghe on 15/12/26.
//  Copyright © 2015年 ibireme. All rights reserved.
//

/// Single picture's info.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XHPhotoProtocol <NSObject>

@required
@property (nonatomic, strong, nullable) NSURL *largeImageURL; ///< 大图url
@property (nonatomic, strong, nullable) UIView *thumbView; ///<used for animation position calculation

@optional
@property (nonatomic, readonly, nullable) UIImage *thumbImage; ///< 缩略图
@property (nonatomic, copy, nullable) NSString *caption;
@property (nonatomic, assign) BOOL shouldClipToTop;///< 是否是长图

@end

@interface XHPhotoItem : NSObject <XHPhotoProtocol>

@property (nonatomic, strong, nullable) NSURL *largeImageURL;
@property (nonatomic, strong, nullable) UIView *thumbView; ///<used for animation position calculation

@property (nonatomic, readonly, nullable) UIImage *thumbImage;
@property (nonatomic, copy, nullable) NSString *caption;
@property (nonatomic, assign) BOOL shouldClipToTop;

+ (BOOL)shouldClipToTopWithView:(UIView * _Nullable)view;

@end

NS_ASSUME_NONNULL_END
