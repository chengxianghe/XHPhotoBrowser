//
//  WMTestViewController.m
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/27.
//  Copyright © 2016年 cn. All rights reserved.
//

#import "WMTestViewController.h"
#import "MWPhotoBrowser.h"

@interface WMTestViewController () <MWPhotoBrowserDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

@end

@implementation WMTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [btn addTarget:self action:@selector(onBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor redColor];
    
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    self.photos = photos;
    self.thumbs = thumbs;

 
}

- (void)onBtn {
    
    for (int i = 0; i < _groupItems.count; i ++) {
        id<XHPhotoProtocol> item = _groupItems[i];
        
        MWPhoto *ph = [MWPhoto photoWithURL:item.largeImageURL];
        ph.caption = item.caption;
        [_photos addObject:ph];
    }
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = NO;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = YES;
    browser.autoPlayOnAppear = YES;
    [browser setCurrentPhotoIndex:0];
    
    // Test custom selection images
    //    browser.customImageSelectedIconName = @"ImageSelected.png";
    //    browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
    
    // Reset selections
    //    if (displaySelectionButtons) {
    //        _selections = [NSMutableArray new];
    //        for (int i = 0; i < photos.count; i++) {
    //            [_selections addObject:[NSNumber numberWithBool:NO]];
    //        }
    //    }
    
    // Show
    //    if (_segmentedControl.selectedSegmentIndex == 0) {
    // Push
    [self.navigationController pushViewController:browser animated:YES];
    //    } else {
    //        // Modal
    //        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    //        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //        [self presentViewController:nc animated:YES completion:nil];
    //    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

//- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
//    return [[_selections objectAtIndex:index] boolValue];
//}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
//    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
//    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
//}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
