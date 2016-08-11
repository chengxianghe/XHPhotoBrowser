//
//  XHPhotoBrowser.h
//  GMBuy
//
//  Created by chengxianghe on 15/9/21.
//  Copyright © 2015年 cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHPhotoBrowserView.h"
#import "XHProgressView.h"

@class XHPhotoBrowser;

@protocol XHPhotoBrowserDelegate <NSObject>

- (UIImage *)photoBrowser:(XHPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;
- (NSURL *)photoBrowser:(XHPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;

@optional
- (BOOL)photoBrowserIsNavigationBarTranslucent;
- (void)photoBrowser:(XHPhotoBrowser *)browser willShowAtIndex:(NSInteger)index;
- (void)photoBrowser:(XHPhotoBrowser *)browser didShowAtIndex:(NSInteger)index;
- (void)photoBrowser:(XHPhotoBrowser *)browser willDismissAtIndex:(NSInteger)index;
- (void)photoBrowser:(XHPhotoBrowser *)browser didDismissAtIndex:(NSInteger)index;

@end

@interface XHPhotoBrowser : UIViewController

///是否支持横屏
@property (nonatomic, assign) BOOL shouldSupportLandscape;

///是否在横屏的时候直接满宽度，而不是满高度，一般是在有长图需求的时候设置为YES
@property (nonatomic, assign) BOOL fullWidthForLandScape;

// 图片间的间距 默认(10.f)
@property (nonatomic, assign) CGFloat imageViewMargin;

// 图片下载进度指示器显示模式 (默认XHIndicatorViewModeLoopDiagram)
@property (nonatomic, assign) XHIndicatorViewMode viewMode;

// 图片下载进度指示器内部控件间的间距 默认(10.f)
@property (nonatomic, assign) CGFloat indicatorViewItemMargin;

// browser消失的动画时长 默认(0.4f)
@property (nonatomic, assign) CGFloat hideDuration;

// browser出现的动画时长 默认(0.3f)
@property (nonatomic, assign) CGFloat showDuration;

//图片最小缩放比例  默认(1.0f)
@property (nonatomic, assign) CGFloat minZoomScale;

//图片最大缩放比例  默认(2.0f)
@property (nonatomic, assign) CGFloat maxZoomScale;

@property (nonatomic, weak) UIViewController *containerVC;
@property (nonatomic, weak) UIView *sourceImagesContainerView;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;//图片总数
@property (nonatomic, strong) UIImage *snapImage;

@property (nonatomic, weak) id<XHPhotoBrowserDelegate> delegate;

/**
 *  展示
 *
 *  @param view         父View
 *  @param container    如controller,navigationController...
 *  @param currentIndex 初始化的index
 *  @param imageCount   数量总数
 *  @param delegate     delegate
 *
 *  @return XHPhotoBrowser
 */
+ (instancetype)showInView:(UIView *)view
                 container:(UIViewController *)container
              currentIndex:(NSInteger)currentIndex
                imageCount:(NSInteger)imageCount
                  delegate:(id<XHPhotoBrowserDelegate>)delegate;


@end
