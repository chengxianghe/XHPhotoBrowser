//
//  XHPhotoGroup.m
//  GMBuy
//
//  Created by chengxianghe on 15/9/21.
//  Copyright © 2015年 cn. All rights reserved.
//


#import "XHPhotoGroup.h"
#import "UIImageView+WebCache.h"
#import "XHPhotoBrowser.h"
#import "PhotoViewFrameHelper.h"

@interface XHPhotoGroup() <XHPhotoBrowserDelegate>
@property (nonatomic, strong) NSArray *photoItemArray;

@end

@implementation XHPhotoGroup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 清除图片缓存，便于测试
        //        [[SDWebImageManager sharedManager].imageCache clearDisk];
        
        //        NSLog(@"++++++++++++创建了9张图");
        for (int i = 0; i < 9; i ++) {
            UIImageView *imageV = [[UIImageView alloc] init];
            
            //            UIButton *btn = [[UIButton alloc] init];
            //让图片不变形，以适应按钮宽高，按钮中图片部分内容可能看不到
            imageV.contentMode = UIViewContentModeScaleAspectFill;
            imageV.clipsToBounds = YES;
            imageV.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClick:)];
            [imageV addGestureRecognizer:tap];
            imageV.tag = i;
            
            [self addSubview:imageV];
            
        }
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    for (int i = 0; i < 9; i ++) {
        UIImageView *imageV = [[UIImageView alloc] init];
        
        //            UIButton *btn = [[UIButton alloc] init];
        //让图片不变形，以适应按钮宽高，按钮中图片部分内容可能看不到
        imageV.contentMode = UIViewContentModeScaleAspectFill;
        imageV.clipsToBounds = YES;
        imageV.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClick:)];
        [imageV addGestureRecognizer:tap];
        
        imageV.tag = i;
        
        [self addSubview:imageV];
    }
    
}

- (void)setXHPhotoGroupIsShowImage:(BOOL)isShowImage {
    
    // 刷新图片数据 (最多展示9张)
    
    /**
     *SDWebImageRetryFailed = 1<< 0,            默认选项，失败后重试
     *SDWebImageLowPriority = 1<< 1,            使用低优先级(列表用)
     *SDWebImageCacheMemoryOnly = 1<< 2,        仅仅使用内存缓存
     *SDWebImageProgressiveDownload = 1<< 3,    显示现在进度
     *SDWebImageRefreshCached = 1<< 4,          刷新缓存
     *SDWebImageContinueInBackground =1 << 5,   后台继续下载图像
     *SDWebImageHandleCookies = 1<< 6,          处理Cookie
     *SDWebImageAllowInvalidSSLCertificates= 1 << 7,    允许无效的SSL验证
     *SDWebImageHighPriority = 1<< 8,           高优先级(优先下载 移到队列最前)
     *SDWebImageDelayPlaceholder = 1<< 9        延迟显示占位图片
     */
    
    [self.subviews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
        
        if (idx < _photoItemArray.count) {
            
            if ([_photoItemArray[idx] isKindOfClass:[XHPhotoItem class]]) {
                
                if (isShowImage) {
                    
                    [self.subviews[idx].layer removeAnimationForKey:@"contents"];
                    
                    
                    [imageView sd_setImageWithURL:[NSURL URLWithString:[_photoItemArray[idx] thumbnail_pic]] placeholderImage:[UIImage imageNamed:@"whiteplaceholder"] options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        
                        if (error != nil) {
                            [imageView setImage:[UIImage imageNamed:@"whiteplaceholder"]];
                            return ;
                        }
                        
                        if (!self.type.length && self.photoItemArray.count == 1) {
                            //                                    CGSize photoViewSize = [PhotoViewFrameHelper size:image.size MatchToSize:self.frame.size];
                            // super.frame = frame;
                            //                                    self.subviews[0].frame = (CGRect){0,0,photoViewSize};
//                            CGFloat width = image.size.width;
//                            CGFloat height = image.size.height;
//                            CGFloat scale = (height / width) / (imageView.bounds.size.height / imageView.bounds.size.width);
//                            if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
//                                imageView.contentMode = UIViewContentModeScaleAspectFill;
//                                imageView.layer.contentsRect = CGRectMake(0, 0, 1, 1);
//                            } else { // 高图只保留顶部
//                                imageView.contentMode = UIViewContentModeScaleToFill;
//                                imageView.layer.contentsRect = CGRectMake(0, 0, 1, width / height);
//                            }
                        }
                        
                        imageView.image = image;
                        
                        if (cacheType != SDImageCacheTypeMemory) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = 0.15;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                            transition.type = kCATransitionFade;
                            [imageView.layer addAnimation:transition forKey:@"contents"];
                        }
                    }];
                    
                } else {
                    [imageView setImage:[UIImage imageNamed:@"whiteplaceholder"]];
                }
            }
            
        }else {
            [imageView setImage:nil];
        }
        
    }];
    
    
    
}

- (void)setPhotoItemArray:(NSArray *)photoItemArray isShowImage:(BOOL)isShowImage
{
    if(![photoItemArray isKindOfClass:[NSArray class]]) {
        return;
    }
    _photoItemArray = photoItemArray;
    
    // 刷新图片布局
    [self setFrameSubviews];
    // 刷新图片数据
    [self setXHPhotoGroupIsShowImage:isShowImage];
}

- (void)setFrameSubviews {
    NSArray *array = [PhotoViewFrameHelper getPhotoViewFramesWithPhotoCount:self.photoItemArray.count andPhotoViewSize:self.frame.size];
    
    for (int i = 0; i < self.subviews.count; i ++) {
        UIView *imageV = self.subviews[i];
        
        if (i<self.photoItemArray.count) {
            imageV.frame = CGRectFromString(array[i]);
        } else {
            imageV.frame = CGRectZero;
        }
    }
}

- (void)buttonClick:(UITapGestureRecognizer *)sender
{
    //启动图片浏览器
    UIViewController *vc = (UIViewController *)[[self getParsentView:self] nextResponder];
    
    [XHPhotoBrowser showInView:self
                     container:vc
                  currentIndex:sender.view.tag
                    imageCount:self.photoItemArray.count
                      delegate:self];
    
//    XHPhotoBrowser *browserVc = [[XHPhotoBrowser alloc] init];
//    browserVc.sourceImagesContainerView = self; // 原图的父控件
//    browserVc.imageCount = self.photoItemArray.count; // 图片总数
//    browserVc.currentImageIndex = (int)sender.view.tag;
//    browserVc.delegate = self;
//    browserVc.containerVC = (UIViewController *)[[self getParsentView:self] nextResponder];
//    
//    UIImage *snapshotImage = [self.class snapshotImageAfterScreenUpdates:YES inView:[UIApplication sharedApplication].keyWindow];
//    browserVc.snapImage = snapshotImage;
//
//    [self.window.rootViewController presentViewController:browserVc animated:NO completion:nil];

}
- (UIView *)getParsentView:(UIView *)view{
    if ([[view nextResponder] isKindOfClass:[UIViewController class]] || view == nil) {
        return view;
    }
    return [self getParsentView:view.superview];
}

#pragma mark - photobrowser代理方法
// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(XHPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    if ([self.subviews[index] isKindOfClass:[UIImageView class]]) {
        return [(UIImageView*)self.subviews[index] image];
    } else {
        return [self.subviews[index] currentImage];
    }
    
}

// 返回高质量图片的url
- (NSURL *)photoBrowser:(XHPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *urlStr = [self.photoItemArray[index] original_pic];
    return [NSURL URLWithString:urlStr];
}

- (void)photoBrowser:(XHPhotoBrowser *)browser willShowAtIndex:(NSInteger)index {
    [(UIView *)self.subviews[index] setHidden:YES];
    NSLog(@"%s", __func__);
}

- (void)photoBrowser:(XHPhotoBrowser *)browser didShowAtIndex:(NSInteger)index {
    [(UIView *)self.subviews[index] setHidden:NO];
    NSLog(@"%s", __func__);

}

- (void)photoBrowser:(XHPhotoBrowser *)browser willDismissAtIndex:(NSInteger)index {
    [(UIView *)self.subviews[index] setHidden:YES];
    NSLog(@"%s", __func__);

}

- (void)photoBrowser:(XHPhotoBrowser *)browser didDismissAtIndex:(NSInteger)index {
    [(UIView *)self.subviews[index] setHidden:NO];
    NSLog(@"%s", __func__);

}

@end
