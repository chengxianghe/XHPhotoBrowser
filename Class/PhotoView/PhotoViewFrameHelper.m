//
//  PhotoViewFrameHelper.m
//  GMBuy
//
//  Created by chengxianghe on 15/9/21.
//  Copyright © 2015年 cn. All rights reserved.
//

#import "PhotoViewFrameHelper.h"
#import "XHPhotoItem.h"

static const CGFloat radio1 = 116 / 154.f;
static const CGFloat radio2 = 176 / 236.f;

#define screenW [UIScreen mainScreen].bounds.size.width

// 默认宽度
#define TEXT_WIDTH      (screenW - 20)
// 默认间距
#define kGap             6
// 9宫格
#define kPhotoWidth1(width)     ((width - 2 * kGap) / 3.f)
// 田字格
#define kPhotoWidth2(width)     ((width - kGap) / 2.f)

@implementation PhotoViewFrameHelper

+ (NSArray *)getPhotoViewFramesWithPhotoCount:(NSInteger)count viewSize:(CGSize)photoSize andGap:(CGFloat)gap {
    
    if (count <= 0) {
        return nil;
    }
    
    if (count == 1) {
        CGFloat photoWidth = (photoSize.width - gap) / 2.f;

        return @[NSStringFromCGRect(CGRectMake(0, 0, photoWidth, photoSize.height))];
    }
    
    NSMutableArray *array = [NSMutableArray array];
    
    
    CGSize onePhotoSize = CGSizeZero;
    NSInteger columns = 0;
    NSInteger row = 0;
    
    if (count == 2 || count == 4) {
        
        // 2/4 张， 单张比例 高度/宽度
        CGFloat photoWidth = (photoSize.width - gap) / 2.f;
        onePhotoSize = CGSizeMake(photoWidth, photoWidth * radio2);
        columns = 2;
        
    } else {
        
        // 单张比例 高度/宽度 9宫格
        CGFloat photoWidth = (photoSize.width - 2 * gap) / 3.f;
        onePhotoSize = CGSizeMake(photoWidth, photoWidth * radio1);
        
        columns = 3;
    }
    
    for (int i = 0; i < count; i ++) {
        row = i/columns;
        NSInteger col = i%columns;
        CGFloat x = col*(onePhotoSize.width + gap);
        CGFloat y = row*(onePhotoSize.height + gap);
        
        CGRect frame = CGRectMake(x, y, onePhotoSize.width, onePhotoSize.height);
        
        [array addObject:NSStringFromCGRect(frame)];
    }
    
    return array;
}

+ (NSArray *)getPhotoViewFramesWithPhotoCount:(NSInteger)count andPhotoViewSize:(CGSize)photoSize {
    return [self getPhotoViewFramesWithPhotoCount:count viewSize:photoSize andGap:kGap];
}

+ (NSArray *)getPhotoViewFramesWithPhotoCount:(NSInteger)count {
    return [self getPhotoViewFramesWithPhotoCount:count andPhotoViewSize:[self getPhotoViewSizeWithPhotoCount:count]];
}

+ (CGSize)getPhotoViewSizeWithPhotoCount:(NSInteger)count {
    
    
    // 一行最多有3列
    CGSize photoViewSize = CGSizeZero;
    
    // 单张比例 高度/宽度 9宫格
    CGSize  photoSize1 = CGSizeMake(kPhotoWidth1(TEXT_WIDTH), kPhotoWidth1(TEXT_WIDTH) * radio1);
    
    // 2/4 张， 单张比例 高度/宽度
    CGSize  photoSize2 = CGSizeMake(kPhotoWidth2(TEXT_WIDTH), kPhotoWidth2(TEXT_WIDTH) * radio2);
    
    photoViewSize.width = TEXT_WIDTH;
    
    
    switch (count) {
        case 0:
            return CGSizeZero;
            break;
            
        case 1:
        case 2:
            // 固定
            photoViewSize.height = photoSize2.height;
            break;
        case 3:
            photoViewSize.height = photoSize1.height;
            break;
            
        case 4:
            photoViewSize.height = photoSize2.height * 2 + kGap;
            break;
            
        case 5:
        case 6:
            photoViewSize.height = photoSize1.height * 2 + kGap;
            break;
            
        default:
            photoViewSize.height =  photoSize1.height * 3 + 2 * kGap;
            break;
    }
    
    return photoViewSize;
}

+ (CGSize)size:(CGSize)imageSize MatchToWidth:(CGFloat)maxWidth {
    
    CGSize newSize = imageSize;
    float radio = imageSize.width / imageSize.height;

    newSize.width = maxWidth;
    newSize.height = ceil(maxWidth/radio);
    
    return newSize;
}

+ (CGSize)size:(CGSize)imageSize MatchToSize:(CGSize)maxSize {
    
    float radio = imageSize.width / imageSize.height;
    float radioMax = maxSize.width / maxSize.height;

    CGSize newSize = imageSize;
    
    if (radio < radioMax) {// 更宽的
        // 宽度限制
        newSize.height = maxSize.height;
        newSize.width = newSize.height * radio;
 
    } else { // 更长的
        // 高度限制
        newSize.width = maxSize.width;
        newSize.height = newSize.width / radio;
    }
    
    return newSize;
}

@end
