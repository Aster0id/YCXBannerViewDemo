//
//  YCXBannerPhoto.m
//  YCXBannerViewDemo
//
//  Created by 牛萌 on 15/12/16.
//  Copyright © 2015年 self.Aster0id. All rights reserved.
//

#import "YCXBannerPhoto.h"
#import "SDWebImageManager.h"


NSString *const kYCXBannerPhotoProgressNotification = @"YCXBannerPhoto.Progress.Notification";
NSString *const kYCXBannerPhotoLoadingDidEndNotification = @"YCXBannerPhoto.LoadingDidEnd.Notification";


@interface YCXBannerPhoto () {
    /// 是否加载中
    BOOL _loadingInProgress;
    /// SDWebImage操作
    id <SDWebImageOperation> _webImageOperation;
}

// 图片资源
@property (nonatomic, strong) UIImage *image;
// 图片链接资源
@property (nonatomic, strong) NSURL   *photoURL;

@end


@implementation YCXBannerPhoto
@synthesize underlyingImage = _underlyingImage;


#pragma mark - Init

+ (YCXBannerPhoto *)initWithImage:(UIImage *)image andCaption:(NSString *)caption {
    YCXBannerPhoto *photo = [[YCXBannerPhoto alloc] initWithImage:image];
    photo.caption = caption;
    return photo;
}

+ (YCXBannerPhoto *)initWithURL:(id)url andCaption:(NSString *)caption {
    YCXBannerPhoto *photo = [[YCXBannerPhoto alloc] initWithURL:url];
    photo.caption = caption;
    return photo;
}

- (id)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        self.image = image;
    }
    return self;
}

- (id)initWithURL:(id)url {
    if ((self = [super init])) {
        if ([url isKindOfClass:[NSURL class]]) {
            self.photoURL = url;
        }
        else if ([url isKindOfClass:[NSString class]]) {
            self.photoURL = [NSURL  URLWithString:url];
        } else {
            NSAssert(NO, @"URL连接不正确");
        }
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}


#pragma mark - YCXBannerPhotoProtocol

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

/// 加载最终图片,并且发送通知
- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    // 如果正在加载, 则退出此方法
    if (_loadingInProgress) return;
    // 否则, 标记为正在加载中
    _loadingInProgress = YES;
    
    @try {
        // 如果根图片存在
        if (self.underlyingImage) {
            // 执行图片加载完成的方法
            [self imageLoadingComplete];
        } else {
            // 否则, 执行加载根图片, 并发送通知
            [self performLoadUnderlyingImageAndNotify];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        _loadingInProgress = NO;
        [self imageLoadingComplete];
    }
    @finally {
    }
}

/// 取消加载
- (void)cancelAnyLoading {
    if (_webImageOperation != nil) {
        [_webImageOperation cancel];
        _loadingInProgress = NO;
    }
}


#pragma mark - Private Methods

/// 执行加载根图片, 并发送通知
- (void)performLoadUnderlyingImageAndNotify {
    
    // 如果图片资源存在
    if (_image) {
        // 则将图片资源赋给根图片
        self.underlyingImage = _image;
        // 同时, 执行图片加载完成的方法
        [self imageLoadingComplete];
        
    }
    // 否则判断图片链接资源是否存在
    else if (_photoURL) {
        // 如果存在, 通过图片URL连接下载图片资源
        [self _performLoadUnderlyingImageAndNotifyWithWebURL: _photoURL];
    }
    // 否则没有找到资源
    else {
        // 直接执行图片加载完成的方法
        [self imageLoadingComplete];
        
    }
}

/// 图片加载完成
- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // 将加载状态置为否
    _loadingInProgress = NO;
    // 在下一个RunLoop中发送完成加载通知
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

/// 通知: 加载完成
- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kYCXBannerPhotoLoadingDidEndNotification object:self];
}

/// 通过图片URL连接下载图片资源
- (void)_performLoadUnderlyingImageAndNotifyWithWebURL:(NSURL *)url {
    @try {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        _webImageOperation = [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (expectedSize > 0) {
                float progress = receivedSize / (float)expectedSize;
                NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:progress], @"progress",
                                      self, @"photo", nil];
                // 发送图片加载中的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:kYCXBannerPhotoProgressNotification object:dict];

            }
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (error) {
                NSLog(@"SDWebImage failed to download image: %@", error);
            }
            _webImageOperation = nil;
            self.underlyingImage = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self imageLoadingComplete];
            });
        }];
    } @catch (NSException *e) {
        NSLog(@"Photo from web: %@", e);
        _webImageOperation = nil;
        [self imageLoadingComplete];
    }
}
 
@end
