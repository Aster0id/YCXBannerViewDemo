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
    NSArray *images =
    @[@"https://raw.githubusercontent.com/Aster0id/TestData/master/img1.jpg",
     @"https://raw.githubusercontent.com/Aster0id/TestData/master/img2.jpg",
      @"https://raw.githubusercontent.com/Aster0id/TestData/master/img3.jpg",
      @"https://raw.githubusercontent.com/Aster0id/TestData/master/img4.jpg"
      ];
    [self.bannerView resetBannerViewWithImagesArray:images andAutoplay:YES];
}


#pragma mark - YCXBannerViewDelegate

- (void)bannerView:(YCXBannerView *)bannerView clickAtIndex:(NSInteger)index {
    NSLog(@"clickAtIndex %zd",index);
}


@end
