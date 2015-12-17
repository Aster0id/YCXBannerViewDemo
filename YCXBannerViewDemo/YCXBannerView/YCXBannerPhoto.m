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

@interface YCXBannerPhoto ()
{
    BOOL _loadingInProgress;
    id <SDWebImageOperation> _webImageOperation;
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *photoURL;

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

- (id)init {
    if ((self = [super init])) {
    }
    return self;
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


#pragma mark - MWPhoto Protocol Methods

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (_loadingInProgress) return;
    _loadingInProgress = YES;
    @try {
        if (self.underlyingImage) {
            [self imageLoadingComplete];
        } else {
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

// Set the underlyingImage
- (void)performLoadUnderlyingImageAndNotify {
    
    // Get underlying image
    if (_image) {
        
        // We have UIImage!
        self.underlyingImage = _image;
        [self imageLoadingComplete];
        
    } else if (_photoURL) {
        
        [self _performLoadUnderlyingImageAndNotifyWithWebURL: _photoURL];
        
    } else {
        
        // Image is empty
        [self imageLoadingComplete];
        
    }
}


/// 图片加载完成
- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    // Notify on next run loop
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kYCXBannerPhotoLoadingDidEndNotification object:self];
}

- (void)cancelAnyLoading {
    if (_webImageOperation != nil) {
        [_webImageOperation cancel];
        _loadingInProgress = NO;
    }
}

#pragma mark - Private Methods

// Load from local file
- (void)_performLoadUnderlyingImageAndNotifyWithWebURL:(NSURL *)url {
    @try {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        _webImageOperation = [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (expectedSize > 0) {
                float progress = receivedSize / (float)expectedSize;
                NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:progress], @"progress",
                                      self, @"photo", nil];
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
