//
//  WMTestViewController.h
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/27.
//  Copyright © 2016年 cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHPhotoBrowser.h"

@interface WMTestViewController : UIViewController
@property (nonatomic, strong, nullable) NSArray<__kindof id <XHPhotoProtocol>> *groupItems;

@end
