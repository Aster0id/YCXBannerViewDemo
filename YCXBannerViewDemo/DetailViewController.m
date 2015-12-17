//
//  DetailViewController.m
//  YCXBannerViewDemo
//
//  Created by 牛萌 on 15/12/16.
//  Copyright © 2015年 self.Aster0id. All rights reserved.
//

#import "DetailViewController.h"
#import "YCXBannerView.h"


@interface DetailViewController ()
<YCXBannerViewDelegate>

@property (nonatomic, weak) IBOutlet YCXBannerView *bannerView;

@end


@implementation DetailViewController


#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray *images;
    
    switch (self.type) {
        case YCXTypeNetwork: {
            images = @[[[YCXBannerPhoto alloc] initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img1.jpg"],
                       [[YCXBannerPhoto alloc] initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img2.jpg"],
                       [[YCXBannerPhoto alloc] initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img3.jpg"],
                       [[YCXBannerPhoto alloc] initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img4.jpg"]
                       ];
        } break;
        case YCXTypeLocal: {
            images =
            @[
              [YCXBannerPhoto initWithImage:[UIImage imageNamed:@"img1.jpg"] andCaption:@"哈哈哈哈哈哈哈哈哈哈哈哈哈哈笑cry"],
              [YCXBannerPhoto initWithImage:[UIImage imageNamed:@"img2.jpg"] andCaption:@"黄沙戈壁"],
              ];
        } break;
        default:
            break;
    }
    
    self.bannerView.delegate = self;
    
    self.bannerView.photosArray = images;
    [self.bannerView reloadData];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Random" style:UIBarButtonItemStylePlain target:self action:@selector(random)];
}

- (void)random {
    NSArray *images =
    @[
      [YCXBannerPhoto initWithImage:[UIImage imageNamed:@"img1.jpg"] andCaption:@"哈哈哈哈哈哈哈哈哈哈哈哈哈哈笑cry"],
      [YCXBannerPhoto initWithImage:[UIImage imageNamed:@"img2.jpg"] andCaption:@"黄沙戈壁"],
      [[YCXBannerPhoto alloc] initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img1.jpg"],
      [[YCXBannerPhoto alloc] initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img2.jpg"],
      [[YCXBannerPhoto alloc] initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img3.jpg"],
      [[YCXBannerPhoto alloc] initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img4.jpg"]
      ];
    
    NSMutableArray *mImages = [images mutableCopy];
    NSInteger imagesCount = mImages.count;
    for (NSInteger i = 0; i < imagesCount; i++) {
        NSInteger target = arc4random() % imagesCount;
        id temp = mImages[target];
        [mImages replaceObjectAtIndex:target withObject:mImages[i]];
        [mImages replaceObjectAtIndex:i withObject:temp];
    }

    [mImages removeObjectsInRange:NSMakeRange(0, (arc4random() % imagesCount))];
    
    self.bannerView.photosArray = mImages;
    [self.bannerView reloadData];
}

#pragma mark - YCXBannerViewDelegate

- (void)bannerView:(YCXBannerView *)bannerView clickAtIndex:(NSInteger)index {
    NSLog(@"clickAtIndex %zd",index);
}


@end
