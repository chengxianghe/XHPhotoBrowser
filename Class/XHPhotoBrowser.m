//
//  XHPhotoBrowser.m
//  GMBuy
//
//  Created by chengxianghe on 15/9/21.
//  Copyright © 2015年 cn. All rights reserved.
//

#import "XHPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SDWebImageManager.h"

#define kLimitHeight (kAppHeight * 3)

@interface XHPhotoBrowser() <UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,assign) BOOL hasShowedPhotoBrowser;
@property (nonatomic,strong) UILabel *indexLabel;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UIButton *saveButton;
@property (nonatomic,weak) UIImageView *snapView;
@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation XHPhotoBrowser

+ (instancetype)showInView:(UIView *)view container:(UIViewController *)container currentIndex:(NSInteger)currentIndex imageCount:(NSInteger)imageCount delegate:(id<XHPhotoBrowserDelegate>)delegate {
   
    XHPhotoBrowser *browserVc = [[XHPhotoBrowser alloc] init];
    browserVc.sourceImagesContainerView = view; // 原图的父控件
    browserVc.imageCount = imageCount; // 图片总数
    browserVc.currentImageIndex = currentIndex;
    browserVc.delegate = delegate;
    browserVc.containerVC = container;
    
    UIImage *snapshotImage = [self.class snapshotImageAfterScreenUpdates:YES inView:[UIApplication sharedApplication].keyWindow];
    browserVc.snapImage = snapshotImage;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:browserVc animated:NO completion:nil];

    return browserVc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reset];
    
    _hasShowedPhotoBrowser = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    //    // 避免一下变黑, 加入渐变效果
    UIImageView *snapView = [[UIImageView alloc] initWithImage:self.snapImage];
    [self.view addSubview:snapView];
    self.snapView = snapView;
    
    [self addScrollView];
    [self addToolbars];
    [self setUpFrames];
}

- (void)reset {
    self.shouldSupportLandscape = YES;
    self.fullWidthForLandScape = YES;
    self.imageViewMargin = 10.0;
    self.indicatorViewItemMargin = 10.0;
    self.hideDuration = 0.4;
    self.showDuration = 0.3;
    self.minZoomScale = 1.0;
    self.maxZoomScale = 2.0;
    self.viewMode = XHIndicatorViewModeLoopDiagram;
}

- (void)dealloc {
    //    NSLog(@"%s", __func__);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_hasShowedPhotoBrowser) {
        [self showPhotoBrowser];
    }
    
    // 隐藏状态栏
    //    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 显示状态栏
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (ALAssetsLibrary *)assetsLibrary {
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

#pragma mark 重置各控件frame（处理屏幕旋转）
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setUpFrames];
}

#pragma mark 设置各控件frame
- (void)setUpFrames
{
    CGRect rect = self.view.bounds;
    rect.size.width += self.imageViewMargin * 2;
    _scrollView.bounds = rect;
    _scrollView.center = CGPointMake(kAPPWidth *0.5, kAppHeight *0.5);
    
    CGFloat y = 0;
    __block CGFloat w = kAPPWidth;
    CGFloat h = kAppHeight;
    
    //设置所有XHPhotoBrowserView的frame
    [_scrollView.subviews enumerateObjectsUsingBlock:^(XHPhotoBrowserView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = self.imageViewMargin + idx * (self.imageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, kAppHeight);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    
    _indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    _indexLabel.center = CGPointMake(kAPPWidth * 0.5, 30);
    _saveButton.frame = CGRectMake(kAPPWidth - 70, kAppHeight - 70, 55, 30);
}

+ (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates inView:(UIView *)view {
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snap;
    }
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

#pragma mark 显示图片浏览器
- (void)showPhotoBrowser
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:willShowAtIndex:)]) {
        [self.delegate photoBrowser:self willShowAtIndex:self.currentImageIndex];
    }
    
    UIView *sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
//    UIView *parentView = [self getParsentView:sourceView];
    UIView *parentView = self.containerVC.view;
    CGRect rect = [sourceView.superview convertRect:sourceView.frame toView:parentView];
    
    id vc = [parentView nextResponder];
    if ([vc isKindOfClass:[UIViewController class]]) {
        UIImage *snapshotImage = [self.class snapshotImageAfterScreenUpdates:YES inView:[(UIViewController *)vc navigationController].view];
        
        self.snapView.image = snapshotImage;
    }
    
    //如果是tableview，要减去偏移量
    if ([parentView isKindOfClass:[UITableView class]]) {
        UITableView *tableview = (UITableView *)parentView;
        rect.origin.y =  rect.origin.y - tableview.contentOffset.y;
    }
    
    rect = [self proofreadOrigin:rect parentView:parentView];
    
    
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.frame = rect;
    tempImageView.image = [self placeholderImageForIndex:self.currentImageIndex];
    [self.view addSubview:tempImageView];
    
    
    CGFloat placeImageSizeW = MAX(1, tempImageView.image.size.width);
    CGFloat placeImageSizeH = MAX(1, tempImageView.image.size.height);
    CGRect targetTemp;
    
    if (!self.fullWidthForLandScape) {
        if (kAPPWidth < kAppHeight) {
            CGFloat placeHolderH = (placeImageSizeH * kAPPWidth)/placeImageSizeW;
            if (placeHolderH <= kAppHeight) {
                targetTemp = CGRectMake(0, (kAppHeight - placeHolderH) * 0.5 , kAPPWidth, placeHolderH);
            } else {
                targetTemp = CGRectMake(0, 0, kAPPWidth, placeHolderH);
            }
        } else {
            CGFloat placeHolderW = (placeImageSizeW * kAppHeight)/placeImageSizeH;
            if (placeHolderW < kAPPWidth) {
                targetTemp = CGRectMake((kAPPWidth - placeHolderW)*0.5, 0, placeHolderW, kAppHeight);
            } else {
                targetTemp = CGRectMake(0, 0, placeHolderW, kAppHeight);
            }
        }
        
    } else {
        CGFloat placeHolderH = (placeImageSizeH * kAPPWidth)/placeImageSizeW;
        if (placeHolderH <= kAppHeight) {
            targetTemp = CGRectMake(0, (kAppHeight - placeHolderH) * 0.5 , kAPPWidth, placeHolderH);
        } else {
            targetTemp = CGRectMake(0, 0, kAPPWidth, placeHolderH);
        }
    }
    
    // 更改显示效果
    if (targetTemp.size.height <= kLimitHeight) {
        tempImageView.contentMode = UIViewContentModeScaleAspectFill;
        tempImageView.clipsToBounds = YES;
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAPPWidth, kAppHeight)];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0;
    [self.view insertSubview:backView belowSubview:tempImageView];
    
    [UIView animateWithDuration:self.showDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        tempImageView.frame = targetTemp;
        backView.alpha = 1.0;
    } completion:^(BOOL finished) {
        _hasShowedPhotoBrowser = YES;
        [tempImageView removeFromSuperview];
        _scrollView.hidden = NO;
        if (self.imageCount) {
            _indexLabel.hidden = NO;
        }
        _saveButton.hidden = NO;
        [backView removeFromSuperview];
        [self.snapView removeFromSuperview];
        self.snapImage = nil;
        if ([self.delegate respondsToSelector:@selector(photoBrowser:didShowAtIndex:)]) {
            [self.delegate photoBrowser:self didShowAtIndex:self.currentImageIndex];
        }
    }];
}


#pragma mark 添加scrollview
- (void)addScrollView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = self.view.bounds;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.hidden = YES;
    [self.view addSubview:_scrollView];
    
    for (int i = 0; i < self.imageCount; i++) {
        XHPhotoBrowserView *view = [[XHPhotoBrowserView alloc] init];
        view.maxZoomScale = self.maxZoomScale;
        view.minZoomScale = self.minZoomScale;
        view.viewMode = self.viewMode;
        view.indicatorViewItemMargin = self.indicatorViewItemMargin;
        view.fullWidthForLandScape = self.fullWidthForLandScape;
        view.imageview.tag = i;
        
        //处理单击
        __weak __typeof(self)weakSelf = self;
        view.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf hidePhotoBrowser:recognizer];
        };
        
        [_scrollView addSubview:view];
    }
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
}

#pragma mark 添加操作按钮
- (void)addToolbars
{
    //序标
    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:20];
    indexLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    indexLabel.bounds = CGRectMake(0, 0, 100, 40);
    indexLabel.center = CGPointMake(kAPPWidth * 0.5, 30);
    indexLabel.layer.cornerRadius = 15;
    indexLabel.clipsToBounds = YES;
    indexLabel.hidden = YES;
    
    if (self.imageCount > 1) {
        indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
        _indexLabel = indexLabel;
        [self.view addSubview:indexLabel];
    }
    
    // 2.保存按钮
    UIButton *saveButton = [[UIButton alloc] init];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.layer.borderWidth = 0.1;
    saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
    saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    saveButton.layer.cornerRadius = 2;
    saveButton.clipsToBounds = YES;
    saveButton.hidden = YES;
    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    _saveButton = saveButton;
    [self.view addSubview:saveButton];
}

#pragma mark 保存图像
- (void)saveImage
{
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    
    XHPhotoBrowserView *currentView = _scrollView.subviews[index];
    UIImage *image = currentView.imageview.image;
    
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.view.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
    
    __weak typeof(self) weak_self = self;
    
    if (image.images.count > 1) { // gif
        NSDictionary *metadata = @{@"UTI":(__bridge NSString *)kUTTypeGIF};
        NSURL *imageURL = [self highQualityImageURLForIndex:index];
        NSData *imageData = nil;
        BOOL isExit = [[SDWebImageManager sharedManager] diskImageExistsForURL:imageURL];
        if (isExit) {
            NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:imageURL];
            if (cacheImageKey.length) {
                NSString *cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
                if (cacheImagePath.length) {
                    imageData = [NSData dataWithContentsOfFile:cacheImagePath];
                }
            }
        }
        if (!imageData) {
            imageData = [NSData dataWithContentsOfURL:imageURL];
        }
        if (!imageData) {
            imageData = UIImagePNGRepresentation(image);
        }
        
        [self.assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
            [weak_self image:image didFinishSavingWithError:error contextInfo:nil];
        }];
    } else {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.50f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 60);
    label.center = self.view.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:21];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = @"保存失败";
    }   else {
        label.text = @"保存成功";
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (CGRect)proofreadOrigin:(CGRect)rect parentView:(id)parentView {
#pragma mark----- 导航栏不透明的时候需要校正
    BOOL navigationBarTranslucent = NO;

    if ([self.delegate respondsToSelector:@selector(photoBrowserIsNavigationBarTranslucent)]) {
        navigationBarTranslucent = [self.delegate photoBrowserIsNavigationBarTranslucent];
    } else {
        id vc = [parentView nextResponder];
        if ([vc isKindOfClass:[UIViewController class]]) {
            navigationBarTranslucent = [(UIViewController *)vc navigationController].navigationBar.translucent;
        }
    }
    
    if (!navigationBarTranslucent) {
        rect.origin.y = rect.origin.y + 64.f;
    }
   
    return rect;
}

#pragma mark 单击隐藏图片浏览器
- (void)hidePhotoBrowser:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:willDismissAtIndex:)]) {
        [self.delegate photoBrowser:self willDismissAtIndex:self.currentImageIndex];
    }
    
    XHPhotoBrowserView *view = (XHPhotoBrowserView *)recognizer.view;
    UIImageView *currentImageView = view.imageview;
    
    UIView *sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
//    UIView *parentView = [self getParsentView:sourceView];
    UIView *parentView = self.containerVC.view;
    CGRect targetTemp = [sourceView.superview convertRect:sourceView.frame toView:parentView];
    
    // 减去偏移量
    if ([parentView isKindOfClass:[UITableView class]]) {
        UITableView *tableview = (UITableView *)parentView;
        targetTemp.origin.y = targetTemp.origin.y - tableview.contentOffset.y;
    }
    
    targetTemp = [self proofreadOrigin:targetTemp parentView:parentView];
    
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.image = currentImageView.image;
    
    CGRect tempF = currentImageView.frame;
    tempF.origin.x += -view.scrollview.contentOffset.x;
    tempF.origin.y += -view.scrollview.contentOffset.y;
    
    tempImageView.frame = tempF;
    
    
    // 添加的黑色背景
    UIView *backView = [[UIView alloc] initWithFrame:self.view.frame];
    backView.backgroundColor = [UIColor blackColor];
    [self.view.window addSubview:backView];
    
    [self.view.window addSubview:tempImageView];
    self.scrollView.hidden = YES;
    
//        NSLog(@"CGRectGetMidY:%f -- navH:%f -- tabH:%f -- kAppHeight:%f", CGRectGetMidY(targetTemp), navH, tabH, kAppHeight);

    if (CGRectGetMidY(targetTemp) - 64 < 0 || CGRectGetMidY(targetTemp) + 49 > kAppHeight) {
        [self dismissViewControllerAnimated:NO completion:^{
            
            // 不在屏幕里面 执行缩放动画
            [UIView animateWithDuration:self.hideDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                tempImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
                backView.alpha = 0;
                tempImageView.alpha = 0;
            } completion:^(BOOL finished) {
                [backView removeFromSuperview];
                [tempImageView removeFromSuperview];
                if ([self.delegate respondsToSelector:@selector(photoBrowser:didDismissAtIndex:)]) {
                    [self.delegate photoBrowser:self didDismissAtIndex:self.currentImageIndex];
                }
            }];
        }];
    } else {
        [self dismissViewControllerAnimated:NO completion:^{
            // 更改显示效果
            if (tempImageView.frame.size.height <= kLimitHeight) {
                tempImageView.contentMode = UIViewContentModeScaleAspectFill;
                tempImageView.clipsToBounds = YES;
            }
            
            // 在屏幕里面 还原到指定位置动画
            [UIView animateWithDuration:self.hideDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                tempImageView.frame = targetTemp;
                backView.alpha = 0;
            } completion:^(BOOL finished) {
                [backView removeFromSuperview];
                [tempImageView removeFromSuperview];
                if ([self.delegate respondsToSelector:@selector(photoBrowser:didDismissAtIndex:)]) {
                    [self.delegate photoBrowser:self didDismissAtIndex:self.currentImageIndex];
                }
            }];
            
        }];
    }
}

#pragma mark 网络加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    XHPhotoBrowserView *view = _scrollView.subviews[index];
    if (view.beginLoadingImage) return;
    if ([self highQualityImageURLForIndex:index]) {
        [view setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    } else {
        view.imageview.image = [self placeholderImageForIndex:index];
    }
    view.beginLoadingImage = YES;
}

#pragma mark 获取控制器的view
//- (UIView *)getParsentView:(UIView *)view{
//    if ([[view nextResponder] isKindOfClass:[UIViewController class]] || view == nil) {
//        return view;
//    }
//    return [self getParsentView:view.superview];
//}

#pragma mark 获取低分辨率（占位）图片
- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

#pragma mark 获取高分辨率图片url
- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}


#pragma mark - scrollview代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    
    _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    long left = index - 2;
    long right = index + 2;
    left = left>0?left : 0;
    right = right>self.imageCount?self.imageCount:right;
    
    //预加载三张图片
    for (long i = left; i < right; i++) {
        [self setupImageOfImageViewForIndex:i];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int autualIndex = scrollView.contentOffset.x  / _scrollView.bounds.size.width;
    //设置当前下标
    self.currentImageIndex = autualIndex;
    
    //将不是当前imageview的缩放全部还原 (这个方法有些冗余，后期可以改进)
    for (XHPhotoBrowserView *view in _scrollView.subviews) {
        if (view.imageview.tag != autualIndex) {
            view.scrollview.zoomScale = 1.0;
        }
    }
}

#pragma mark 横竖屏设置
- (BOOL)shouldAutorotate {
    return self.shouldSupportLandscape;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.shouldSupportLandscape) {
        return UIInterfaceOrientationMaskAll;
    } else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
