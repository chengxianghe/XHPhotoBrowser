//
//  XHPhotoGroup.h
//  GMBuy
//
//  Created by chengxianghe on 15/9/21.
//  Copyright © 2015年 cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHPhotoItem.h"

@interface XHPhotoGroup : UIView 

- (void)setPhotoItemArray:(NSArray <__kindof XHPhotoItem *> *)photoItemArray isShowImage:(BOOL)isShowImage;

- (void)setXHPhotoGroupIsShowImage:(BOOL)isShowImage;

@property (strong ,nonatomic) NSString *type;
@end
