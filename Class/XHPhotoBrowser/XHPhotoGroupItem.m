//
//  YYPhotoGroupItem.m
//  YYKitDemo
//
//  Created by chengxianghe on 15/12/26.
//  Copyright © 2015年 ibireme. All rights reserved.
//

#import "XHPhotoGroupItem.h"

@implementation XHPhotoGroupItem

- (UIImage *)thumbImage {
    if ([_thumbView respondsToSelector:@selector(image)]) {
        return [(UIImageView *)_thumbView image];
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    XHPhotoGroupItem *item = [self.class new];
    return item;
}

@end
