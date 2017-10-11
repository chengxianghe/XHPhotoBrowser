//
//  XHPhotoBrowserController.m
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/27.
//  Copyright © 2016年 cn. All rights reserved.
//

#import "XHPhotoBrowserController.h"
#import "XHPhotoBrowserHeader.h"

@interface XHPhotoBrowserController () <XHPhotoBrowserDelegate, XHPhotoBrowserDataSource> {
    BOOL _previousNavBarHidden;
}

@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL navBarAnimating;
@property (nonatomic, strong) UIView *customNavView;
@property (nonatomic, strong) UILabel *customNavTitleLabel;

@end

@implementation XHPhotoBrowserController

- (id)init {
    if ((self = [super init])) {
        [self _initialisation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        [self _initialisation];
    }
    return self;
}

- (void)dealloc {
    [_browser dismissAnimated:NO completion:nil];
    _browser = nil;
}

- (void)_initialisation {
    self.hidesBottomBarWhenPushed = YES;
    _showBrowserWhenDidload = YES;
    _previousNavBarHidden = self.navigationController.navigationBar.hidden;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    XHPhotoBrowser *browser = [[XHPhotoBrowser alloc] init];
    browser.delegate = self;
    browser.dataSource = self;
    browser.showDeleteButton = NO;
    browser.toolBarShowStyle = XHShowStyleShow;
    browser.showCloseButton = NO;
    browser.upDownDismiss = NO;
    browser.fromItemIndex = 0;
    browser.blurEffectBackground = NO;
    browser.showToolBarWhenScroll = NO;
    browser.showCaptionWhenScroll = NO;
    browser.singleTapOption = XHSingleTapOptionNone;
    browser.pager.style = XHPageControlStyleNone;
    _browser = browser;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_previousNavBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!_previousNavBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat navH = kIs_Inch5_8 ? 88 : 64;
    CGFloat statusH = kStatusBarHeight;
    
    self.customNavView = [[UIView alloc] init];
    [self.customNavView setFrame:CGRectMake(0, 0, kScreenWidth, navH)];
    self.customNavView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.customNavView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    self.customNavTitleLabel = titleLabel;
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [titleLabel setFrame:CGRectMake(0, 0, 200, 40)];
    [titleLabel setCenter:CGPointMake(kScreenWidth * 0.5, (navH + statusH) * 0.5)];
    [self.customNavView addSubview:titleLabel];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.rightImage == nil) {
        self.rightImage = [UIImage imageNamed:@"XHPhotoBrowser.bundle/images/btn_common_more_wh"];
    }
    [rightBtn setFrame:CGRectMake(kScreenWidth - 50, statusH, 40, 40)];
    [rightBtn setImage:self.rightImage forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavView addSubview:rightBtn];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(5, statusH + 10, 30, 20)];
    [backBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [backBtn setImage:[UIImage imageNamed:@"XHPhotoBrowser.bundle/images/btn_common_back_wh"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavView addSubview:backBtn];
    
    self.browser.fromItemIndex = self.fromItemIndex;
    if (_showBrowserWhenDidload) {
        [_browser showInContaioner:self.view animated:NO completion:nil];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view bringSubviewToFront:self.customNavView];
}

#pragma mark - Action

- (void)onMore:(id)sender {
    if (_moreBlock) {
        _moreBlock();
    }
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIStatusBar

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - XHPhotoBrowserDataSource

- (NSInteger)xh_numberOfImagesInPhotoBrowser:(XHPhotoBrowser *)photoBrowser {
    return self.groupItems.count;
}

- (id<XHPhotoProtocol>)xh_photoBrowser:(XHPhotoBrowser *)photoBrowser photoAtIndex:(NSInteger)index {
    return self.groupItems[index];
}

#pragma mark - XHPhotoBrowserDelegate

- (void)xh_photoBrowserSingleTap:(XHPhotoBrowser *)photoBrowser {
    if (self.navBarAnimating) return;
    
    CGFloat duration = 0.2;
    self.navBarAnimating = YES;
    [UIView animateWithDuration:duration animations:^{
        
        self.statusBarHidden = self.customNavView.xh_top >= 0;
        self.customNavView.xh_top = self.statusBarHidden ? -self.customNavView.xh_height : 0;
        [self setNeedsStatusBarAppearanceUpdate];
        
        
    } completion:^(BOOL finished) {
        if (finished) {
            self.navBarAnimating = NO;
        }
    }];
}

- (void)xh_photoBrowser:(XHPhotoBrowser *)photoBrowser didDisplayingImageAtIndex:(NSInteger)index fromIndex:(NSInteger)fromIndex {
    self.title = [NSString stringWithFormat:@"%d / %d", (int)index + 1, (int)photoBrowser.groupItems.count];
    [self.customNavTitleLabel setText:self.title];
}

- (void)xh_photoBrowserDidDismiss:(XHPhotoBrowser *)photoBrowser {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
