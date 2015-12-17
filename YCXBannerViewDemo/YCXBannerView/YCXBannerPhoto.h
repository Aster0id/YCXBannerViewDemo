//
//  YCXBannerPhoto.h
//  YCXBannerViewDemo
//
//  Created by 牛萌 on 15/12/16.
//  Copyright © 2015年 self.Aster0id. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Notifications
#define MWPHOTO_LOADING_DID_END_NOTIFICATION @"MWPHOTO_LOADING_DID_END_NOTIFICATION"
#define MWPHOTO_PROGRESS_NOTIFICATION @"MWPHOTO_PROGRESS_NOTIFICATION"


@interface YCXBannerPhoto : NSObject

/// 文字说明
@property (nonatomic, strong) NSString *caption;

@property (nonatomic, strong) UIImage *underlyingImage;

+ (YCXBannerPhoto *)initWithImage:(UIImage *)image andCaption:(NSString *)caption;
+ (YCXBannerPhoto *)initWithURL:(id)url andCaption:(NSString *)caption;

- (id)initWithImage:(UIImage *)image;
- (id)initWithURL:(id)url;


// Cancel any background loading of image data
- (void)cancelAnyLoading;

- (void)loadUnderlyingImageAndNotify;

@end
