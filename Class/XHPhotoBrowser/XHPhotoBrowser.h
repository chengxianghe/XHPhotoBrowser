//
//  YYPhotoGroupView.h
//  YYKitDemo
//
//  Created by chengxianghe on 15/12/26.
//  Copyright © 2015年 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHPhotoGroupItem.h"
#import "XHPageControlView.h"

NS_ASSUME_NONNULL_BEGIN

@class XHPhotoBrowser;


typedef NS_ENUM(NSUInteger, XHShowStyle) {
    XHShowStyleAuto,
    XHShowStyleHide,
    XHShowStyleShow,
};

@protocol XHPhotoBrowserDataSource <NSObject>

@required

- (NSInteger)xh_numberOfImagesInPhotoBrowser:(XHPhotoBrowser * _Nonnull)photoBrowser;

- (id <XHPhotoProtocol> _Nonnull)xh_photoBrowser:(XHPhotoBrowser * _Nonnull)photoBrowser photoAtIndex:(NSInteger)index;

@end

@protocol XHPhotoBrowserDelegate <NSObject>

@optional

- (void)xh_photoBrowserDidTapDelete:(XHPhotoBrowser * _Nonnull)photoBrowser photoAtIndex:(NSInteger)index deleteBlock:(void(^)())deleteBlock;

- (void)xh_photoBrowserSingleTap:(XHPhotoBrowser * _Nonnull)photoBrowser;

- (void)xh_photoBrowserWillDisplay:(XHPhotoBrowser * _Nonnull)photoBrowser;
- (void)xh_photoBrowserDidDisplay:(XHPhotoBrowser * _Nonnull)photoBrowser;

- (void)xh_photoBrowserWillDismiss:(XHPhotoBrowser * _Nonnull)photoBrowser;
- (void)xh_photoBrowserDidDismiss:(XHPhotoBrowser * _Nonnull)photoBrowser;

- (void)xh_photoBrowserWillMoveToSuperView:(XHPhotoBrowser * _Nonnull)photoBrowser;
- (void)xh_photoBrowserWillRemoveFromSuperView:(XHPhotoBrowser * _Nonnull)photoBrowser;


- (void)xh_photoBrowser:(XHPhotoBrowser * _Nonnull)photoBrowser didDisplayingImageAtIndex:(NSInteger)index fromIndex:(NSInteger)fromIndex;

- (void)xh_photoBrowserDidOrientationChange:(XHPhotoBrowser * _Nonnull)photoBrowser;

@end

/// Used to show a group of images.
/// One-shot.
@interface XHPhotoBrowser : UIView

@property (nonatomic, weak, nullable) id <XHPhotoBrowserDataSource> dataSource;
@property (nonatomic, weak, nullable) id <XHPhotoBrowserDelegate> delegate;

@property (nonatomic, readonly, nullable) NSArray<__kindof id <XHPhotoProtocol>> *groupItems;

@property (nonatomic, readonly) NSInteger currentPage;

/**
 *  初始化展示的第一页
 */
@property (nonatomic, assign) NSInteger fromItemIndex;

@property (nonatomic, assign) XHPageControlStyle pageStyle;

/**
 *  是否需要模糊背景(Default is YES)
 */
@property (nonatomic, assign) BOOL blurEffectBackground;

/**
 *  工具条显示样式(Default is Auto)
 */
@property (nonatomic, assign) XHShowStyle toolBarShowStyle;

/**
 *  是否在翻页时显示toolBar(Default is YES)
 */
@property (nonatomic, assign) BOOL showToolBarWhenScroll;

/**
 *  是否在翻页时显示caption(Default is YES)
 */
@property (nonatomic, assign) BOOL showCaptionWhenScroll;

/**
 *  是否上下滑动消失(Default is YES)
 */
@property (nonatomic, assign) BOOL upDownDismiss;

/**
 *  是否消失当单击并且没有caption的时候(Default is YES)
 */
@property (nonatomic, assign) BOOL tapDismissWhenCaptionNone;


/**
 *  thumbView是否是cell(Default is NO)
 *  当thumbView是tableView的cell,或者是collectionView的cell的时候需要设置为YES
 */
@property (nonatomic, assign) BOOL thumbViewIsCell;

/**
 *  默认是否展示删除按钮(Default is NO)
 */
@property (nonatomic, assign) BOOL showDeleteButton;

/**
 *  默认是否展示关闭按钮(Default is YES)
 *  当 'caption.length > 0' 的时候 单击会 '显示/隐藏' caption, 这个时候可以通过关闭按钮退出相册
 */
@property (nonatomic, assign) BOOL showCloseButton;

/**
 *  默认的图片间距(Default is 20)
 */
@property (nonatomic, assign) CGFloat imagePadding;

/**
 *  当 'thumbView.superView 是 scrollView' 的时候, 需要设置这个值修正 '打开/关闭' 的动画
 */
@property (nonatomic, assign) CGFloat contentOffSetY;

/**
 *  默认最大的captionView的高度(Default is 150)
 */
@property (nonatomic, assign) CGFloat maxCaptionHeight;


//- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 *  初始化
 *  该初始化不需要设置delegate和dataSource,一般简单使用
 *  如果使用该初始化方法,同时设置了dataSource,以dataSource返回的数据为准
 *
 *  @return XHPhotoBrowser
 */
- (instancetype)initWithGroupItems:(NSArray<__kindof id <XHPhotoProtocol>> *)groupItems;

/**
 *  展示
 *
 *  @param container   展示的容器
 *  @param currentPage 展示的初始页面
 *  @param animated    是否需要动画
 *  @param completion  完成的回调
 */
- (void)showInContaioner:(UIView * _Nonnull)container
                animated:(BOOL)animated
              completion:(nullable void (^)(void))completion;

/**
 *  退出
 *
 *  @param animated   是否需要动画
 *  @param completion 完成的回调
 */
- (void)dismissAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;

/**
 *  刷新数据只有当设置了dataSource才有作用
 *  数据会清空重新加载
 */
- (void)reloadData;

/**
 *  刷新部分数据
 */
- (void)reloadDataInRange:(NSRange)range;

@end
NS_ASSUME_NONNULL_END
