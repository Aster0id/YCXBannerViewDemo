//
//  YCXBannerPhotoProtocol.h
//  YCXBannerViewDemo
//
//  Created by 牛萌 on 15/12/17.
//  Copyright © 2015年 self.Aster0id. All rights reserved.
//

#import <Foundation/Foundation.h>


/// 通知:图片加载完成
UIKIT_EXTERN NSString *const kYCXBannerPhotoLoadingDidEndNotification;
//#define MWPHOTO_LOADING_DID_END_NOTIFICATION @"MWPHOTO_LOADING_DID_END_NOTIFICATION"
/// 通知:图片加载进度
UIKIT_EXTERN NSString *const kYCXBannerPhotoProgressNotification;
//#define MWPHOTO_PROGRESS_NOTIFICATION @"MWPHOTO_PROGRESS_NOTIFICATION"

@protocol YCXBannerPhotoProtocol <NSObject>

/// 最终用于显示的图片
@property (nonatomic, strong) UIImage *underlyingImage;

/// 取消加载
- (void)cancelAnyLoading;

/// 加载最终图片,并且发送通知
- (void)loadUnderlyingImageAndNotify;

@end
