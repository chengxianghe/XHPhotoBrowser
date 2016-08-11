//
//  XHProgressView.h
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/11.
//  Copyright © 2016年 cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    XHIndicatorViewModeLoopDiagram, // 环形
    XHIndicatorViewModePieDiagram // 饼型
} XHIndicatorViewMode;

@interface XHProgressView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) XHIndicatorViewMode viewMode;//显示模式
@property (nonatomic, assign) CGFloat indicatorViewItemMargin;

@end
