//
//  YCXBannerPhotoView.h
//  YCXBannerViewDemo
//
//  Created by 牛萌 on 15/12/16.
//  Copyright © 2015年 self.Aster0id. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCXBannerPhoto.h"

@class YCXBannerPhotoView;


typedef void(^TapPhotoView)(YCXBannerPhotoView *);


@interface YCXBannerPhotoView : UIView

/// PhotoView的索引
@property (nonatomic, assign) NSUInteger index;
/// 视图中加载的Photo
@property (nonatomic, strong) YCXBannerPhoto *photo;
/// 点击视图的Block
@property (nonatomic, copy)   TapPhotoView tapPhotoView;

@end
