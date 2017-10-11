//
//  XHActionSheet.m
//  XHActionSheet
//
//  Created by chengxianghe on 15/12/31.
//  Copyright © 2015年 CXH. All rights reserved.
//

#import "XHActionSheet.h"

#ifndef kScreenHeight
#define kScreenHeight               [UIScreen mainScreen].bounds.size.height
#endif

#ifndef kScreenWidth
#define kScreenWidth                [UIScreen mainScreen].bounds.size.width
#endif

#define kMaxHeight                  (kScreenHeight - 100)

#define kTitleFont                  [UIFont systemFontOfSize:12.0]
#define KTitleMaxSize               CGSizeMake(kScreenWidth-20, 100)

#define kTopViewBackColor           [UIColor colorWithWhite:0 alpha:0.4]

#define kItemBackColor              [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6]
#define kItemHighligntBackColor     [UIColor colorWithWhite:1 alpha:0.3]
#define kItemFont                   [UIFont systemFontOfSize:15.0]
#define kItemTextColor              [UIColor blackColor]
#define kItemHeight                 (50.0)
#define kItemLineHeight             (1.0 / [UIScreen mainScreen].scale)

#define kCancelSpacing              (7.0)
#define kBtnTagBegin                (100)
#define kDefaultAnimateTime         (0.2)
/**
 Synthsize a weak or strong reference.
 
 Example:
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif


@interface XHActionSheetCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;     //

@end

@implementation XHActionSheetCell {
    UIView *_line;
}

+ (instancetype)actionSheetCellWithTableView:(UITableView *)tableView {
    XHActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XHActionSheetCell"];
    if (!cell) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XHActionSheetCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = kItemFont;
        self.titleLabel.textColor = kItemTextColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1];
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:_line];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = kItemBackColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _line.frame = CGRectMake(0, 0, kScreenWidth, kItemLineHeight);
    _titleLabel.frame = self.contentView.bounds;
}

@end

@interface ActionSheetItem : NSObject
@property (nonatomic,   copy) NSString  *title;     //
@property (nonatomic, strong) UIColor   *titleColor;     //
@end

@implementation ActionSheetItem
@end

@interface XHActionSheet () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic,   copy) XHActionSheetClick clickBlock;
@property (nonatomic,   copy) XHActionSheetCancel cancelBlock;

@property (nonatomic,   copy) NSString  *title;
@property (nonatomic,   copy) NSString  *cancelTitle;
@property (nonatomic, strong) NSMutableArray *otherTitles;
@property (nonatomic,   weak) UIView    *bottomView;
@property (nonatomic,   weak) UILabel   *titleLabel;     //
@property (nonatomic,   weak) UIView    *topView;
@property (nonatomic, strong) UITableView *tableView;     //
@property (nonatomic, assign) BOOL isShowing;     // 是否正在展示

@end

@implementation XHActionSheet

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)showInView:(UIView *)view
                     title:(NSString *)title
               cancelTitle:(NSString *)cancelTitle
               otherTitles:(NSArray *)otherTitles
                    custom:(XHActionSheetCustom)custom
                clickIndex:(XHActionSheetClick)clickIndex
                    cancel:(XHActionSheetCancel)cancel {
    
    XHActionSheet *actionSheet = [[XHActionSheet alloc] initWithTitle:title
                                                          cancelTitle:cancelTitle
                                                          otherTitles:otherTitles];
    
    [actionSheet showInView:view
                     custom:custom
                 clickIndex:clickIndex
                     cancel:cancel];
    return actionSheet;
}

- (instancetype)initWithTitle:(NSString *)title
                  cancelTitle:(NSString *)cancelTitle
                  otherTitles:(NSArray *)otherTitles {
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        
        _title = title;
        _cancelTitle = cancelTitle;
        
        _otherTitles = [NSMutableArray array];
        
        for (int i = 0; i < otherTitles.count; i ++) {
            ActionSheetItem *item = [[ActionSheetItem alloc] init];
            item.titleColor = kItemTextColor;
            item.title = otherTitles[i];
            [_otherTitles addObject:item];
        }
        
        [self configUI];
    }
    return self;
}

- (void)changeActionSheetTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = _title;
    [self layoutSubviews];
}

- (void)changeItemTitleColor:(UIColor *)color
                   withIndex:(NSInteger)index {
    
    if (index >= 0 && index <= _otherTitles.count) {
        if (index == 0) {
            UIButton *btn = [_bottomView viewWithTag:kBtnTagBegin];
            [btn setTitleColor:color forState:UIControlStateNormal];
            
        } else if (index > 0) {
            ActionSheetItem *item = _otherTitles[index - 1];
            item.titleColor = color;
            if (_isShowing) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

- (void)changeItemTitle:(NSString *)title withIndex:(NSInteger)index {
    if (index >= 0 && index <= _otherTitles.count) {
        if (index == 0) {
            UIButton *btn = [_bottomView viewWithTag:kBtnTagBegin];
            [btn setTitle:title forState:UIControlStateNormal];
            
            if (!title.length || !_cancelTitle.length) {
                _cancelTitle = title;
                [self layoutSubviews];
            } else {
                _cancelTitle = title;
            }
            
        } else if (index > 0) {
            ActionSheetItem *item = _otherTitles[index - 1];
            item.title = title;
            if (_isShowing) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            
        }
    }
}

- (void)showInView:(UIView *)view
            custom:(XHActionSheetCustom _Nullable)custom
        clickIndex:(XHActionSheetClick _Nullable)clickIndex
            cancel:(XHActionSheetCancel _Nullable)cancel {
    
    if (custom) {
        custom(self, self.titleLabel);
    }
    
    self.clickBlock = clickIndex;
    self.cancelBlock = cancel;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarOrientationNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarOrientationChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    view = nil;
    
    if (!view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    [view addSubview:self];
    
    _isShowing = YES;
    
    [self animationShow];
}

- (void)animationShow {
    CGSize size = [_title boundingRectWithSize:KTitleMaxSize
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:kTitleFont}
                                       context:nil].size;
    
    CGFloat titleHeight = size.height == 0 ? 0 : (size.height + kItemHeight);
    CGFloat cancelHeight = _cancelTitle.length > 0 ? (kItemHeight + kCancelSpacing) : 0;
    CGFloat totalHeight = _otherTitles.count * kItemHeight + titleHeight + cancelHeight;
    
    if (totalHeight > kMaxHeight) {
        totalHeight = kMaxHeight;
    }
    
    CGFloat selfW = CGRectGetWidth(self.bounds);
    CGFloat selfH = CGRectGetHeight(self.bounds);
    
    [_topView setFrame:CGRectMake(0, 0, selfW, selfH)];
    [_bottomView setFrame:CGRectMake(0, selfH, selfW, totalHeight)];
    @weakify(self);
    [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self.topView setFrame:CGRectMake(0, 0, selfW, selfH - totalHeight)];
        self.topView.alpha = 1.0;
        [self.bottomView setFrame:CGRectMake(0, selfH - totalHeight, selfW, totalHeight+10)];
        
    } completion:^(BOOL finished) {
        @strongify(self);
        if (!self) {return;}
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        tap.delegate = self;
        [self.topView addGestureRecognizer:tap];
        [self.bottomView setFrame:CGRectMake(0, selfH - totalHeight, selfW, totalHeight)];
        [UIView animateWithDuration:kDefaultAnimateTime animations:^{
            //            if (totalHeight > selfH) {
            //                [self layoutIfNeeded];
            //            }
        }];
    }];
}

- (void)statusBarOrientationChange:(NSNotification *)notification {
    [self layoutIfNeeded];
}

-(void)layoutSubviews {
    
    if (_isShowing == NO) {
        return;
    }
    
    [self setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    [super layoutSubviews];
    
    CGFloat selfW = CGRectGetWidth(self.bounds);
    CGFloat selfH = CGRectGetHeight(self.bounds);
    
    CGSize size = [_title boundingRectWithSize:KTitleMaxSize
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:_titleLabel.font}
                                       context:nil].size;
    
    CGFloat titleHeight = size.height == 0 ? 0 : (size.height + 50);
    CGFloat cancelHeight = _cancelTitle.length > 0 ? (kItemHeight + kCancelSpacing) : 0;
    CGFloat totalHeight = _otherTitles.count * kItemHeight + titleHeight + cancelHeight;
    
    if (totalHeight > kMaxHeight) {
        totalHeight = kMaxHeight;
    }
    
    [_topView setFrame:CGRectMake(0, 0, selfW, selfH - totalHeight)];
    
    // bottomView
    [_bottomView setFrame:CGRectMake(0, selfH - totalHeight, selfW, totalHeight)];
    _tableView.frame = CGRectMake(0, titleHeight, selfW, totalHeight - titleHeight - cancelHeight);
    _tableView.bounces = _tableView.contentSize.height > _tableView.frame.size.height;
    _tableView.showsVerticalScrollIndicator = _tableView.bounces;
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        UIVisualEffectView *effectView = [_bottomView viewWithTag:8080];
        effectView.frame = _bottomView.bounds;
    }
    
    [_titleLabel.superview setFrame:CGRectMake(0, 0, selfW, titleHeight)];
    [_titleLabel setFrame:CGRectMake(10, 0, selfW - 20, titleHeight)];
    
    UIButton *cancelBtn = (UIButton *)[_bottomView viewWithTag:kBtnTagBegin];
    if (cancelHeight > 0) {
        [cancelBtn setFrame:CGRectMake(0, totalHeight - kItemHeight, selfW, kItemHeight)];
    } else {
        [cancelBtn setFrame:CGRectMake(0, totalHeight, selfW, 0)];
    }
}

- (void)configUI{
    
    UIView *TopView = [[UIView alloc] init];
    TopView.backgroundColor = kTopViewBackColor;
    TopView.alpha = 0;
    [self addSubview:TopView];
    _topView = TopView;
    
    //bottomView
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
    [self addSubview:bottomView];
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        [effectView setTag:8080];
        [bottomView addSubview:effectView];
        bottomView.backgroundColor = [UIColor clearColor];
    }
    
    _bottomView = bottomView;
    
    // table
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = kItemHeight;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [_bottomView addSubview:_tableView];
    
    // title
    UIView *titleView = [[UIView alloc] init];
    titleView.backgroundColor = kItemBackColor;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = kTitleFont;
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.text = _title;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:titleLabel];
    [bottomView addSubview:titleView];
    _titleLabel = titleLabel;
    
    UIButton *canceBtn = [self getActionButton];
    [canceBtn setTitle:_cancelTitle forState:UIControlStateNormal];
    [canceBtn setTag:kBtnTagBegin];
    [bottomView addSubview:canceBtn];
}

- (UIButton *)getActionButton {
    UIButton *btn = [[UIButton alloc] init];
    
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:kItemBackColor];
    [btn titleLabel].font = kItemFont;
    [btn addTarget:self action:@selector(selectedButtons:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(selectHighlight:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [btn addTarget:self action:@selector(scaleToDefault:) forControlEvents:UIControlEventTouchDragExit];
    
    return btn;
}

-(void)selectHighlight:(UIButton *)btn{
    [UIView animateWithDuration:kDefaultAnimateTime animations:^{
        [btn setBackgroundColor:kItemHighligntBackColor];
    }];
}

- (void)scaleToDefault:(UIButton *)btn{
    [UIView animateWithDuration:kDefaultAnimateTime animations:^{
        [btn setBackgroundColor:kItemBackColor];
    }];
}

- (void)selectedButtons:(UIButton *)btns{
    [self selectedIndex:btns.tag - kBtnTagBegin];
}

- (void)selectedIndex:(NSInteger)index {
    @weakify(self);
    [self dismissViewWithCompletion:^{
        @strongify(self);
        if (!self) return;
        
        if (self.clickBlock) {
            self.clickBlock(index);
        }
    }];
    
}

- (void)dismiss:(UITapGestureRecognizer *)tap{
    if(!CGRectContainsPoint(self.frame, [tap locationInView:_bottomView])) {
        @weakify(self);
        [self dismissViewWithCompletion:^{
            @strongify(self);
            if (!self) return;
            if (self.cancelBlock) {
                self.cancelBlock();
            }
        }];
    }
}

-(void)dismissViewWithCompletion:(void(^)(void))completion{
    
    _isShowing = NO;
    
    @weakify(self);
    CGFloat totalHeight = CGRectGetHeight(self.bottomView.frame);
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.topView setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        [self.topView setBackgroundColor:[UIColor clearColor]];
        [self.bottomView setFrame:CGRectMake(0, kScreenHeight, kScreenWidth, totalHeight)];
    } completion:^(BOOL finished) {
        if (finished) {
            @strongify(self);
            if (!self) return;
            if (completion) {
                completion();
            }
            [self removeFromSuperview];
        }
        
    }];
    
}

- (void)removeFromSuperview{
    NSArray *SubViews = [self subviews];
    for (id obj in SubViews) {
        [obj removeFromSuperview];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

#pragma mark
#pragma mark - UITableView - DataSorce
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.otherTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XHActionSheetCell *cell = [XHActionSheetCell actionSheetCellWithTableView:tableView];
    ActionSheetItem *item = self.otherTitles[indexPath.row];
    
    cell.titleLabel.text = item.title;
    cell.titleLabel.textColor = item.titleColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self selectedIndex:indexPath.row + 1];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:kDefaultAnimateTime animations:^{
        [cell setBackgroundColor:kItemHighligntBackColor];
    }];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:kDefaultAnimateTime animations:^{
        [cell setBackgroundColor:kItemBackColor];
    }];
}

@end
