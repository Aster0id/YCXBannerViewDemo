//
//  YCXBannerPhoto.h
//  YCXBannerViewDemo
//
//  Created by 牛萌 on 15/12/16.
//  Copyright © 2015年 self.Aster0id. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "YCXBannerPhotoProtocol.h"


@interface YCXBannerPhoto : NSObject <YCXBannerPhotoProtocol>

/// 图片描述
@property (nonatomic, strong) NSString *caption;

+ (YCXBannerPhoto *)initWithImage:(UIImage *)image andCaption:(NSString *)caption;

+ (YCXBannerPhoto *)initWithURL:(id)url andCaption:(NSString *)caption;

- (id)initWithImage:(UIImage *)image;

- (id)initWithURL:(id)url;

@end
