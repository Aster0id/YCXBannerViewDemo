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
{
    YCXBannerView *_banner1;
}

#pragma mark - Lifecycle Methods


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray *images;
    
    switch (self.type) {
        case YCXTypeNetwork: {
            images =
            @[
              [YCXBannerPhoto initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img1.jpg" andCaption:nil],
              [YCXBannerPhoto initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img2.jpg" andCaption:@"好风景"],
              [YCXBannerPhoto initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img3.jpg" andCaption:nil],
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
    
    
    _banner1 = [[YCXBannerView alloc] init];
    _banner1.photosArray = [self randomPhotoArray];
    _banner1.delegate = self;
    _banner1.frame = CGRectMake(0, self.view.frame.size.width*10/16.0 + 10 + 10, self.view.frame.size.width, self.view.frame.size.width/2);
    [self.view addSubview:_banner1];
    
    [_banner1 reloadData];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Random" style:UIBarButtonItemStylePlain target:self action:@selector(random)];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}


- (void)random {
    self.bannerView.photosArray = [self randomPhotoArray];
    [self.bannerView reloadData];
}

- (NSArray *)randomPhotoArray {
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
    return mImages;
}

#pragma mark - YCXBannerViewDelegate

- (void)bannerView:(YCXBannerView *)bannerView clickAtIndex:(NSInteger)index {
    NSLog(@"%@ \n>>>>>> clickAtIndex %zd",bannerView ,index);
}


@end
