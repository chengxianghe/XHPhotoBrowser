//
//  XHPhotoBrowserView.h
//  GMBuy
//
//  Created by chengxianghe on 15/9/21.
//  Copyright © 2015年 cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHProgressView.h"

#ifndef kAPPWidth
#define kAPPWidth [UIScreen mainScreen].bounds.size.width
#endif

#ifndef kAppHeight
#define kAppHeight [UIScreen mainScreen].bounds.size.height
#endif

@interface XHPhotoBrowserView : UIView
@property (nonatomic,strong) UIScrollView *scrollview;
@property (nonatomic,strong) UIImageView *imageview;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL beginLoadingImage;
@property (nonatomic, assign) BOOL fullWidthForLandScape;

@property (nonatomic, assign) XHIndicatorViewMode viewMode;//显示模式
@property (nonatomic, assign) CGFloat indicatorViewItemMargin;

@property (nonatomic, assign) CGFloat minZoomScale;
@property (nonatomic, assign) CGFloat maxZoomScale;

//单击回调
@property (nonatomic, strong) void (^singleTapBlock)(UITapGestureRecognizer *recognizer);

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
@end
